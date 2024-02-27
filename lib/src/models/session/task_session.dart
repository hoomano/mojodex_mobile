import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojodex_mobile/src/models/session/session.dart';

import '../error_notifier.dart';
import '../tasks/produced_text.dart';
import 'messages/message.dart';
import 'messages/mojo_message.dart';
import 'messages/user_message.dart';

class TaskSession extends Session {
  TaskSession(
      {required super.sessionId,
      required int userTaskExecutionPk,
      required this.onReceivedNewDraft,
      required this.onReceivedUserTaskExecutionTitle,
      required this.correctProducedText,
      required this.onUserTaskExecutionStarted}) {
    _userTaskExecutionPk = userTaskExecutionPk;
  }

  late int _userTaskExecutionPk;
  String? onGoingDraftTitle;
  String? onGoingDraftProduction;
  // Is MojoDrafting ? = sending draft tokens ?
  bool _mojoDrafting = false;
  bool get mojoDrafting => _mojoDrafting;

  @override
  MojoMessage mojoMessageFromMap(
      Map<String, dynamic> messageMap, int messagePk) {
    return MojoMessage(
        text: messageMap['text'],
        taskToolExecutionPk: messageMap.containsKey('task_tool_execution_fk')
            ? messageMap['task_tool_execution_fk']
            : null,
        hasAudio: messageMap['audio'],
        messagePk: messagePk);
  }

  @override
  void ackMojoMessage(Map<String, dynamic> messageMap, int messagePk,
      Function(dynamic) callback) {
    var callBackMap = {'session_id': sessionId};
    if (messageMap.containsKey('produced_text_version_pk')) {
      callBackMap['produced_text_version_pk'] =
          messageMap['produced_text_version_pk'].toString();
    } else {
      callBackMap['message_pk'] = messagePk.toString();
    }
    callback(callBackMap);
  }

  @override
  void onSocketioError(dynamic data) {
    logger.severe("Error in session: $data");
    if (data.containsKey('user_message_pk')) {
      int userMessagePk = data['user_message_pk'];
      UserMessage? message =
          getMessageFromPk(userMessagePk, MessageSender.user) as UserMessage?;
      if (message == null) {
        // should never happened
        // send error message to backend
        String errorMessage = "Received error message from socketio: $data\n"
            "but user_message_pk not found in local session messages";
        put(
            service: 'error',
            body: {'error': errorMessage, 'notify_admin': true});
        logger.severe("No message found for pk $userMessagePk");
        ErrorNotifier().errorController.add(errorMessage);
        return;
      }
      if (message.taskToolExecutionPk == null) {
        // the contrary should never happened as it is an HTTP call with no socketio transaction related
        message.failEmission(
            "User message failed emission. Received error through onSocketioError with data: $data");
        waitingForMojo = false;
        notifyListeners();
        return;
      }
    } else {
      super.onSocketioError(data);
    }
  }

  Future<bool> acceptTaskToolExecution() async {
    int taskToolExecutionPk = messages[0].taskToolExecutionPk!;
    messages[0].taskToolExecutionAcceptedByUser = true;
    UserMessage message =
        UserMessage(text: "OK", taskToolExecutionPk: taskToolExecutionPk);
    addMessageToLocalList(message);
    Map<String, dynamic>? accepted =
        await _sendTaskTookExecutionAcceptation(taskToolExecutionPk);
    if (accepted == null) return false;
    message.messagePk = accepted['message_pk'];
    return true;
  }

  void refuseTaskToolExecution() {
    messages[0].taskToolExecutionAcceptedByUser = false;
    notifyListeners();
    return;
  }

  Future<Map<String, dynamic>?> _sendTaskTookExecutionAcceptation(
      int taskToolExecutionPk) async {
    return await post(
        service: 'task_tool_execution',
        body: {"task_tool_execution_pk": taskToolExecutionPk});
  }

  final StreamController<bool> draftStarted = StreamController.broadcast();
  Stream<bool> get draftStartedStream => draftStarted.stream;

  final StreamController<Map<String, dynamic>?> _draftTokenController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>?> get draftTokenStream =>
      _draftTokenController.stream;

  void onDraftToken(dynamic data) {
    if (!mojoDrafting) {
      draftStarted.add(true);
      _mojoDrafting = true;
    }
    if (data is Map && data.containsKey('produced_text')) {
      final map = {
        'title': data['produced_text_title'] ?? '',
        'text': data['produced_text'] ?? '',
        'done': false
      };
      onGoingDraftTitle = map['title'];
      onGoingDraftProduction = map['text'];
      _draftTokenController.add(map.cast<String, dynamic>());
      onMojoToken(data);
    }
  }

  /// on user message acked callback
  Function(ProducedText) onReceivedNewDraft;

  void onReceivedDraft(dynamic data) {
    bool shouldBeTreated = onMojoMessage(data);
    if (!shouldBeTreated) {
      return;
    }
    Map<String, dynamic> messageMap = data[0];
    ProducedText producedText = ProducedText(
        producedTextPk: messageMap['produced_text_pk'],
        producedTextVersionPk: messageMap['produced_text_version_pk'],
        title: messageMap['produced_text_title'],
        production: messageMap['produced_text'],
        audioManager: messages.isNotEmpty ? messages.first.audioManager : null);
    onReceivedNewDraft(producedText);
    _mojoDrafting = false;
    onGoingDraftProduction = null;
    onGoingDraftTitle = null;
    draftStarted.add(false);
    _draftTokenController.add({
      'title': producedText.title,
      'text': producedText.production,
      'done': true
    });
  }

  final StreamController<String> _userTaskExecutionTitleController =
      StreamController.broadcast();
  Stream<String> get userTaskExecutionTitleStream =>
      _userTaskExecutionTitleController.stream;

  Function(String) onReceivedUserTaskExecutionTitle;

  Function(String, String) correctProducedText;

  void onUserTaskExecutionTitle(dynamic data) {
    onReceivedUserTaskExecutionTitle(data["title"]);
    _userTaskExecutionTitleController.add(data["title"]);
  }

  final Function(DateTime) onUserTaskExecutionStarted;

  void onUserTaskExecutionStartedCallback(dynamic data) {
    onUserTaskExecutionStarted(DateTime.parse(data["start_date"]));
  }

  @override
  void onFinishSpellingCorrection(String correctedText) {
    correctMessages(correctedText);
    correctProducedText(textPortionInCorrection!, correctedText);
    try {
      sendVocabToBackend(textPortionInCorrection!, correctedText);
    } catch (e) {
      logger.shout("Error in _sendVocabToBackend exception: $e");
    }
    textPortionInCorrection = null;
  }

  @override
  Map<String, bool> get_placeholders() {
    return {
      "use_message_placeholder": dotenv.env['USE_PLACEHOLDERS'] == "true" &&
          messages.length ==
              1, // if it is the first message, let's Mojo answer by a simple message
      "use_draft_placeholder": dotenv.env['USE_PLACEHOLDERS'] == "true" &&
          messages.length >
              1 // if we already had an exchange, let's respond with a draft
    };
  }

  @override
  String getMessageParams({offset = 0, maxMessagesByCall = 10, older = true}) {
    String params = super.getMessageParams(
        offset: offset, maxMessagesByCall: maxMessagesByCall, older: older);
    return "$params&user_task_execution_pk=${_userTaskExecutionPk}";
  }

  @override
  Future<Map<String, dynamic>?> sendUserMessage(UserMessage message,
      {int retry = 3, String origin = 'task'}) async {
    return super.sendUserMessage(message, retry: retry, origin: origin);
  }
}
