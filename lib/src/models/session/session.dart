import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/session/messages/mojo_message.dart';
import 'package:mojodex_mobile/src/models/session/messages/user_message.dart';
import 'package:mojodex_mobile/src/models/session/socketio_connector.dart';

import '../error_notifier.dart';
import 'messages/audio_manager.dart';
import 'messages/message.dart';

class Session extends ChangeNotifier with HttpCaller {
  // Logger
  final Logger logger = Logger('Session');

  // Session ID
  String sessionId;

  // Are we waiting for Mojo to send us a message?
  bool _waitingForMojo = false;
  bool get waitingForMojo => _waitingForMojo;
  set waitingForMojo(bool waitingForMojo) {
    _waitingForMojo = waitingForMojo;
    notifyListeners();
  }

  String? onGoingMojoMessage;

  // List of messages in the session
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  void markMessageAsResubmitted(UserMessage message) {
    message.retry();
    _waitingForMojo = true;
    notifyListeners();
  }

  Future<bool> reSubmit(
    UserMessage message,
  ) async {
    logger.info("resubmitMessage");
    markMessageAsResubmitted(message);
    return await _sendMessage(message);
  }

  void onSendMessageFailed(UserMessage message, String errorMessage) {
    message.failEmission(errorMessage);
    _waitingForMojo = false;
    notifyListeners();
  }

  void _tagProperNounsOfMessage(UserMessage message) {
    _getTaggedUserMessage(message).then((taggedMessage) {
      if (taggedMessage != null) {
        message.text = taggedMessage["tagged_text"];
        notifyListeners();
      }
    });
  }

  Future<bool> _sendMessage(UserMessage message) async {
    try {
      Map<String, dynamic>? messageData = await sendUserMessage(message);
      if (messageData == null || messageData.containsKey("error")) {
        logger.severe("_sendAudioMessage failed");
        onSendMessageFailed(
            message, "Failed to send user message - error: $messageData");
        return false;
      }
      message.receivedText(messageData['text'], messageData['message_pk']);
      _tagProperNounsOfMessage(message);
    } catch (e) {
      logger.severe("_sendAudioMessage failed");
      onSendMessageFailed(message, "Failed to send user message $e");
      return false;
    }

    return true;
  }

  void addMessageToLocalList(UserMessage message) {
    // 1. add message to _messages at position 0
    _waitingForMojo = true;
    _messages.insert(0, message);
    notifyListeners();
  }

  void removeLastUserMessage() {
    _messages.removeAt(0);
    notifyListeners();
  }

  Future<bool> addMessage(UserMessage message) async {
    addMessageToLocalList(message);
    return await _sendMessage(message);
  }

  // Boolean to know if the session is already loading messages
  bool loadingMessages = false;

  final StreamController<String?> _mojoTokenController =
      StreamController.broadcast();
  Stream<String?> get mojoTokenStream => _mojoTokenController.stream;

  void onMojoToken(dynamic data) {
    if (data is Map && data.containsKey('text')) {
      _mojoTokenController.add(data['text']);
      onGoingMojoMessage = data['text'];
      _waitingForMojo = true;
    }
  }

  @protected
  Message? getMessageFromPk(int messagePk, MessageSender sender) {
    return _messages.firstWhereOrNull((message) =>
        message.sender == sender && message.messagePk == messagePk);
  }

  @protected
  MojoMessage mojoMessageFromMap(
      Map<String, dynamic> messageMap, int messagePk) {
    return MojoMessage(
      text: messageMap['text'],
      hasAudio: messageMap['audio'],
      messagePk: messagePk,
      suggestedTaskFirstMessage: messageMap.containsKey('task_instruction')
          ? messageMap['task_instruction']
          : null,
      suggestedTaskPlaceholderQuestion:
          messageMap.containsKey('task_placeholder_question')
              ? messageMap['task_placeholder_question']
              : null,
      suggestedTaskPlaceholderInstruction:
          messageMap.containsKey('task_placeholder_instruction')
              ? messageMap['task_placeholder_instruction']
              : null,
    );
  }

  @protected
  void ackMojoMessage(Map<String, dynamic> messageMap, int messagePk,
      Function(dynamic) callback) {
    var callBackMap = {'session_id': sessionId};
    callBackMap['message_pk'] = messagePk.toString();
    callback(callBackMap);
  }

  // returns false if message should not be treated (already treated)
  bool onMojoMessage(dynamic data) {
    Map<String, dynamic> messageMap = data[0];
    int messagePk = messageMap['message_pk'];
    Function(dynamic) callback = data[1];
    ackMojoMessage(messageMap, messagePk, callback);

    // Following is for avoiding receving duplicate messages if backend did not received ack which happens with slow network
    // - _messages.isEmpty is for dealing with the case where you were chatting, went back to the task list (there session.messages is cleared idk why) and then went back to the chat
    // here messages are empty but you are still receiving missed acked messages
    // - getMessageFromPk(messagePk) != null is for dealing with the case where you are chatting live
    if (_messages.isEmpty ||
        getMessageFromPk(messagePk, MessageSender.agent) != null) {
      logger.fine("Already received message => dropping");
      return false; // maybe the backend missed a ack
    }

    MojoMessage message = mojoMessageFromMap(messageMap, messagePk);

    if (message.hasAudio) {
      message.audioManager = AudioManager(getAudioFile: message.getVoice);
    }
    _messages.insert(0, message);
    _waitingForMojo = false;
    onGoingMojoMessage = null;
    notifyListeners();
    return true;
  }

  Session({required this.sessionId});

  ///
  /// [
  ///   {
  ///     message_pk: 19175,
  ///     sender: mojo,
  ///     message: {
  ///       text: Please provide me with the information about the meeting, such as the date, time, attendees, and key points discussed, so I can help you prepare the meeting minutes. Is there any additional information you'd like to include?,
  ///     },
  ///     audio: true
  ///   }
  /// ]
  Future<Map<String, dynamic>?> _getMessages(
      {offset = 0, maxMessagesByCall = 10, older = true}) async {
    String params = getMessageParams(
        offset: offset, maxMessagesByCall: maxMessagesByCall, older: older);
    return await get(service: "message", params: params);
  }

  @protected
  String getMessageParams({offset = 0, maxMessagesByCall = 10, older = true}) {
    return "datetime=${DateTime.now().toIso8601String()}&session_id=$sessionId&n_messages=$maxMessagesByCall&offset=$offset&offset_direction=${older ? "older" : "newer"}";
  }

  bool loadingNewerMessages = false;

  Future<void> resubmitOldMessagesInError() async {
    // if last message is a user_message in error
    if (messages.isNotEmpty &&
        messages.last is UserMessage &&
        (messages.last as UserMessage).emissionFailed) {
      reSubmit(messages.last as UserMessage);
    }
  }

  /// Load more messages from the backend
  Future<List<Message>> loadMoreMessages(
      {required int nMessages, bool loadOlder = true}) async {
    if (loadingMessages) return _messages;
    loadingMessages = true;
    if (!loadOlder) {
      loadingNewerMessages = true;
    }
    Map? messagesData = await _getMessages(
      offset: _messages.length,
      maxMessagesByCall: nMessages,
      older: loadOlder,
    );

    if (messagesData != null) {
      List<Message> loadedMessages = messagesData["messages"]
          .where((element) => !element["message"].containsKey("error"))
          .map<Message>((messageData) {
        if (messageData["sender"] == "mojo") {
          return MojoMessage.fromJson(messageData);
        } else {
          UserMessage userMessage = UserMessage.fromJson(messageData);
          if (userMessage.emissionFailed) {
            reSubmit(userMessage);
          }
          return userMessage;
        }
      }).toList();
      if (loadedMessages.isNotEmpty &&
          loadedMessages[0].sender == MessageSender.agent) {
        _waitingForMojo = false;
      }
      if (loadOlder) {
        _messages.addAll(loadedMessages);
      } else {
        _messages.insertAll(0, loadedMessages);
      }
    }
    loadingMessages = false;
    if (!loadOlder) {
      loadingNewerMessages = false;
    }
    notifyListeners();
    return _messages;
  }

  void onUserMessageAcked(dynamic data) {
    // check last message has no transcript yet
    if (_messages.isNotEmpty &&
        _messages[0] is UserMessage &&
        !_messages[0].acked) {
      UserMessage message = _messages[0] as UserMessage;
      message.ack();
    }
  }

  void onSocketioError(dynamic data) {
    logger.severe("Error in session: $data");

    // related to something else than a user message => Better to disconnect !
    String errorMessage = "Received error message from socketio: $data\n"
        "But front doesn't know how to manage";
    ErrorNotifier().errorController.add(errorMessage);
    put(service: 'error', body: {'error': errorMessage, 'notify_admin': true});
  }

  void connectToSession() {
    SocketioConnector().connectSession(this);
  }

  @protected
  Map<String, bool> get_placeholders() {
    return {
      "use_message_placeholder": dotenv.env['USE_PLACEHOLDERS'] == "true"
    };
  }

  @protected
  Future<Map<String, dynamic>?> sendUserMessage(UserMessage message,
      {int retry = 3,
      String origin = 'home_chat',
      int? userTaskExecutionPk}) async {
    try {
      String service = "user_message";
      Map<String, dynamic> formData = {
        'session_id': sessionId,
        'message_date': message.creationDate.toIso8601String(),
        // this id is to avoid sending multiple time the same message to whisper, backend will check it is not already treating it.
        'message_id': "${message.creationDate.toIso8601String()}_$sessionId",
        'message_pk': message.hasMessagePk ? message.messagePk : null,
        'origin': origin
      }..addAll(get_placeholders());
      if (!message.hasAudio) {
        // for auto-send message for example
        formData['text'] = message.text;
      }
      if (userTaskExecutionPk != null) {
        formData['user_task_execution_pk'] = userTaskExecutionPk.toString();
      }

      Map<String, dynamic>? response;
      try {
        response = await putMultipart(
            service: service,
            formData: formData,
            filePath: (!message.hasMessagePk && message.hasAudio)
                ? message.localAudioPath
                : null,
            silentError: true,
            returnError: true);
      } catch (error) {
        if (error is DioException) {
          if (retry > 0) {
            logger.info(
                "_sendUserMessage: received response error: ${error.type} - ${error.message} - ${error.error} - ${error.response} - retrying in 4s");
            await Future.delayed(const Duration(seconds: 4));
            logger.info("_sendUserMessage - retry ${retry - 1}");
            return await sendUserMessage(message,
                retry: retry - 1,
                origin: origin,
                userTaskExecutionPk: userTaskExecutionPk);
          } else {
            try {
              return error.response?.data as Map<String, dynamic>;
            } on Exception {
              return null;
            }
          }
        } else {
          rethrow;
        }
      }

      if (response != null) {
        if (response.containsKey("status") &&
            response["status"] == "processing" &&
            retry > 0) {
          logger.info(
              "🔁 _sendUserMessage: received response 'processing' - retry ${retry - 1}");
          await Future.delayed(const Duration(seconds: 4));
          return await sendUserMessage(message,
              retry: retry - 1,
              origin: origin,
              userTaskExecutionPk: userTaskExecutionPk);
        }
      }
      return response;
    } catch (e) {
      logger.shout("Error in _sendUserMessage exception: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getTaggedUserMessage(
      UserMessage message) async {
    if (!message.hasMessagePk) {
      logger.shout("Message has no pk yet !");
      return null;
    }
    return await post(
        service: 'vocabulary', body: {'message_pk': message.messagePk});
  }

  String? _textPortionInCorrection;
  String? get textPortionInCorrection => _textPortionInCorrection;
  @protected
  set textPortionInCorrection(String? textPortionInCorrection) {
    _textPortionInCorrection = textPortionInCorrection;
    notifyListeners();
  }

  void correctSpell(String textPortion) {
    textPortionInCorrection = textPortion;
  }

  @protected
  void correctMessages(String correctedText) {
    for (Message message in _messages) {
      message.text = message.text.replaceAll(
          RegExp(_textPortionInCorrection!, caseSensitive: false),
          correctedText);
    }
  }

  void onFinishSpellingCorrection(String correctedText) {
    correctMessages(correctedText);
    try {
      sendVocabToBackend(_textPortionInCorrection!, correctedText);
    } catch (e) {
      logger.shout("Error in _sendVocabToBackend exception: $e");
    }
    textPortionInCorrection = null;
  }

  void abandonSpellingCorrection() {
    textPortionInCorrection = null;
  }

  @protected
  Future<Map<String, dynamic>?> sendVocabToBackend(
      String initialSpelling, String correctedSpelling) async {
    return await put(service: "vocabulary", body: {
      "session_id": sessionId,
      "initial_spelling": initialSpelling,
      "corrected_spelling": correctedSpelling
    });
  }
}
