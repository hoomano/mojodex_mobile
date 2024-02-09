import 'package:device_calendar/device_calendar.dart';
import 'package:logging/logging.dart';

import '../user/user.dart';

class CalendarManager {
  final Logger logger = Logger('CalendarManager');

  // Unique instance of the class
  static final CalendarManager _instance = CalendarManager.privateConstructor();

  // Private constructor of the class, called once when the class is created
  CalendarManager.privateConstructor();

  factory CalendarManager() => _instance;

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  // boolean to store whether or not access has been granted
  // when the call to permissions have been done once to prevent doing whole call again
  // Should not be access directly. Use appHasAccess() instead.
  bool? _appHasAccessPermission;

  // List of all calendars accessed from _deviceCalendarPlugin
  // to prevent doing whole call again
  List<Calendar>? _allCalendars;

  // Set permissions to null to force recheck
  // Useful when user change permissions in settings
  void resetPermission() {
    _appHasAccessPermission = null;
    _allCalendars = null;
  }

  // Check if some calendars are allowed for access
  Future<bool> areSomeCalendarsAllowed() async {
    bool areSomeCalendarsAllowed = (await allCalendars).isNotEmpty;
    return areSomeCalendarsAllowed;
  }

  // Check if app has access system access to calendar
  Future<bool> appHasAccess() async {
    if (_appHasAccessPermission != null) {
      return _appHasAccessPermission!;
    }
    Result<bool> permission = await _deviceCalendarPlugin.hasPermissions();
    _appHasAccessPermission = permission.data!;
    return _appHasAccessPermission!;
  }

  // Check if a specific calendar is authorized for access
  bool calendarIsAuthorized(String calendarId) {
    return User().authorizedCalendarIds!.contains(calendarId);
  }

  // Remove a specific calendar from authorized calendars
  void unauthorizeCalendar(String calendarId) {
    List<String> authorizedCalendarIds = User().authorizedCalendarIds!;
    if (authorizedCalendarIds.contains(calendarId)) {
      authorizedCalendarIds.remove(calendarId);
      User().authorizedCalendarIds = authorizedCalendarIds;
    }
  }

  // Add a specific calendar to authorized calendars
  void authorizeCalendar(String calendarId) {
    List<String> authorizedCalendarIds = User().authorizedCalendarIds!;
    if (!authorizedCalendarIds.contains(calendarId)) {
      authorizedCalendarIds.add(calendarId);
      User().authorizedCalendarIds = authorizedCalendarIds;
    }
  }

  // Toggle authorization of a specific calendar
  void changeCalendarAuthorization(String calendarId) {
    if (calendarIsAuthorized(calendarId)) {
      unauthorizeCalendar(calendarId);
    } else {
      authorizeCalendar(calendarId);
    }
  }

  // Trigger the system popup to ask for calendar access if not already done
  // If the system has already been asked, the popup will not be triggered again
  Future<bool> askCalendarPermission() async {
    if (User().askedForCalendarAccessOnce) {
      return false;
    }
    Result<bool> permission = await _deviceCalendarPlugin.requestPermissions();
    User().askedForCalendarAccessOnce = true;
    _appHasAccessPermission = permission.data!;
    return _appHasAccessPermission!;
  }

  // Get the list of all calendars the plugin can access
  Future<List<Calendar>> get allCalendars async {
    // if authorized calendars already retrieved, return them
    if (_allCalendars != null) {
      return _allCalendars!;
    }
    // else, check if app has access to calendar
    await appHasAccess();
    if (!_appHasAccessPermission!) {
      return [];
    }

    // if app has access, retrieve all calendars
    final result = await _deviceCalendarPlugin.retrieveCalendars();
    List<Calendar> calendars = result.data as List<Calendar>;
    // if User().authorizedCalendarIds is not initialized, add all calendars.id to it
    if (User().authorizedCalendarIds == null) {
      // add all calendars.id to User().authorizedCalendarIds
      logger.finer("Adding all calendars to User().authorizedCalendarIds");
      User().authorizedCalendarIds =
          calendars.map((calendar) => calendar.id!).toList();
    }
    _allCalendars = calendars;
    return _allCalendars!;
  }

  // Get the list of all authorized calendars
  Future<List<Calendar>> getAuthorizedCalendars() async {
    List<Calendar> calendars = await allCalendars;
    calendars = calendars
        .where(
            (calendar) => User().authorizedCalendarIds!.contains(calendar.id))
        .toList();
    return calendars;
  }

  // Get the list of all events from a specific calendar between two dates
  Future<List<Event>> getEventsFromCalendar(String calendarId,
      {required DateTime startDate, required DateTime endDate}) async {
    final result = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startDate, endDate: endDate),
    );
    List<Event> events = result.data as List<Event>;
    return events;
  }

  // Get the list of all events from all authorized calendars between two dates
  Future<List<Event>> getEventsFromAuthorizedCalendars(
      {required DateTime startDate, required DateTime endDate}) async {
    List<Calendar> calendars = await getAuthorizedCalendars();
    List<Event> events = [];
    for (Calendar calendar in calendars) {
      List<Event> eventsFromCalendar = await getEventsFromCalendar(calendar.id!,
          startDate: startDate, endDate: endDate);
      events.addAll(eventsFromCalendar);
    }
    return events;
  }

  // Get the list of today events from all authorized calendars
  Future<List<Event>> getTodayEventsFromAuthorizedCalendars() async {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return await getEventsFromAuthorizedCalendars(
        startDate: start, endDate: end);
  }
}
