import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/status_bar/status_bar_data.dart';

import '../calendar_manager/calendar_manager.dart';
import '../language/system_language.dart';
import '../tasks/user_task.dart';
import '../user/user.dart';

enum calendarSuggestionStatus {
  off,
  noCalendarAccess,
  waiting,
  ready,
  isEmpty,
  error
}

class CalendarSuggestion with HttpCaller {
  final Logger logger = Logger('CalendarSuggestion');

  // Unique instance of the class
  static final CalendarSuggestion _instance =
      CalendarSuggestion.privateConstructor();

  // Private constructor of the class, called once when the class is created
  CalendarSuggestion.privateConstructor();

  factory CalendarSuggestion() => _instance;

  // Calendar suggestion ID from backend, set once the calendar suggestion is added to the DB
  late int calendarSuggestionPk;

  // ValueNotifier to notify the UI when the status of the calendar suggestion and its changes
  final ValueNotifier<calendarSuggestionStatus> _status =
      ValueNotifier<calendarSuggestionStatus>(calendarSuggestionStatus.off);
  ValueNotifier<calendarSuggestionStatus> get status => _status;

  late String suggestionEmoji;
  late String suggestionTitle;
  late String suggestionBody;

  late String _waitingText;
  late String _readyText;

  // Eventual task to propose to the user is any for displaying corresponding TaskCard in the calendar suggestion
  UserTask? userTaskToPropose;

  // Generate the calendar suggestion from the events of the day
  // Returns true if the calendar suggestion has been generated successfully, false otherwise
  Future<void> retrieveSuggestion(
      Map<String, dynamic> calendarSuggestionData) async {
    try {
      if (_status.value == calendarSuggestionStatus.error ||
          _status.value == calendarSuggestionStatus.ready) {
        // if error => Message took too long to arrive
        // if ready => Message already arrived
        return;
      }
      if (calendarSuggestionData.containsKey("error")) {
        _status.value = calendarSuggestionStatus.error;
        return;
      }

      if (calendarSuggestionData.isEmpty) {
        _status.value = calendarSuggestionStatus.isEmpty;
      }
      suggestionBody = calendarSuggestionData['message_text'];
      suggestionEmoji = calendarSuggestionData['message_emoji'] ?? '';
      suggestionTitle = calendarSuggestionData['message_title'] ?? '';
      int? taskPk = calendarSuggestionData['task_pk'];
      if (taskPk != null) {
        userTaskToPropose = User().userTasksList.getUserTaskFromTaskPk(taskPk);
      }
      _status.value = calendarSuggestionStatus.ready;
      StatusBarData().text = _readyText;
    } catch (e) {
      _status.value = calendarSuggestionStatus.error;
      return;
    }
  }

  Future<List<Event>?> _extractTodayEvents() async {
    // are some calendars allowed ?
    bool calendarAccess = await CalendarManager().areSomeCalendarsAllowed();
    if (!calendarAccess) {
      // we just wont initialize the suggestion so it will not be displayed
      logger.info("No calendar access, suggestion will not be initialized");
      _status.value = calendarSuggestionStatus.noCalendarAccess;
      StatusBarData().text =
          SystemLanguage().getText(key: "calendar.statusBarAskAccess");
      if (!User().hasAlreadyDoneTask) {
        return null;
      }
      if (!User().askedForCalendarAccessOnce) {
        StatusBarData().displayed.value = true;
      }
      return null;
    }

    // Get today's events from authorized calendars
    return await CalendarManager().getTodayEventsFromAuthorizedCalendars();
  }

  Future<void> getWaitingSentence(List<Event> events) async {
    // events to json
    List<Map<String, dynamic>> eventsJson = events
        .map((e) => {
              "eventId": e.eventId,
              "eventAllDay": e.allDay,
              "eventDescription": e.description,
              "eventStartDate": e.start?.toIso8601String(),
              "eventEndDate": e.end?.toIso8601String(),
              "eventTitle": e.title,
              "eventLocation": e.location,
              "recurrenceRule": e.recurrenceRule?.toJson()
            })
        .toList();
    Map<String, dynamic>? calendarSuggestionData =
        await put(service: 'calendar_suggestion', body: {
      "user_planning": eventsJson,
      "use_placeholder": dotenv.env['USE_PLACEHOLDERS'] == "true"
    });
    if (calendarSuggestionData == null) {
      _status.value = calendarSuggestionStatus.error;
      return;
    }
    if (calendarSuggestionData.isEmpty) {
      _status.value = calendarSuggestionStatus.isEmpty;
      return;
    }
    calendarSuggestionPk = calendarSuggestionData['calendar_suggestion_pk'];
    _waitingText = calendarSuggestionData['waiting_message'];
    _readyText = calendarSuggestionData['ready_message'];
    // Generate the suggestion message from the events of the day
    _status.value = calendarSuggestionStatus.waiting;
    StatusBarData().text = _waitingText;
  }

  // Initialize the suggestion message at the start of the app
  Future<void> init() async {
    List<Event>? events = await _extractTodayEvents();
    if (events == null) {
      // we didn't have calendar access, let's drop it
      return;
    }
    await getWaitingSentence(events);
    if (_status.value == calendarSuggestionStatus.error ||
        _status.value == calendarSuggestionStatus.isEmpty) {
      return;
    }
    StatusBarData().displayed.value = true;

    // wait for 90 seconds, if status is still not ready, turn it to error
    Future.delayed(Duration(seconds: 90), () {
      if (_status.value == calendarSuggestionStatus.waiting) {
        _status.value = calendarSuggestionStatus.error;
      }
    });
  }

  // Answer the suggestion message by a love reaction or starting the proposed task
  Future<void> answer(
      {bool userReacted = false, int? userTaskExecutionPk}) async {
    await post(service: 'calendar_suggestion', body: {
      "calendar_suggestion_pk": calendarSuggestionPk,
      "user_reacted": userReacted,
      "user_task_execution_pk": userTaskExecutionPk
    });
  }
}
