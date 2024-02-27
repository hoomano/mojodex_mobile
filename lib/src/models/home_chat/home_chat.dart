import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/session/messages/mojo_message.dart';

import '../session/messages/audio_manager.dart';
import '../session/session.dart';

class HomeChat with HttpCaller {
  final Logger logger = Logger('HomeChat');

  // Unique instance of the class
  static final HomeChat _instance = HomeChat.privateConstructor();

  // Private constructor of the class, called once when the class is created
  HomeChat.privateConstructor();

  factory HomeChat() => _instance;

  late Session session;

  late int pk;

  late String initialMessageHeader;
  late String initialMessageBody;

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _refreshing = false;
  bool get refreshing => _refreshing;

  bool inError = false;

  Future<void> init() async {
    try {
      String params =
          'use_message_placeholder=${dotenv.env['USE_PLACEHOLDERS'] == "true"}';
      Map<String, dynamic>? homeChatData =
          await get(service: 'home_chat', params: params);

      if (homeChatData == null) {
        inError = true;
        initialMessageHeader = "Something went wrong";
        initialMessageBody = "Error BODY";
        return;
      }
      pk = homeChatData['home_chat_pk'];
      String sessionId = homeChatData['session_id'];
      initialMessageHeader = homeChatData['message'].containsKey("header")
          ? homeChatData['message']['header']
          : "";
      initialMessageBody = homeChatData['message'].containsKey("body")
          ? homeChatData['message']['body']
          : homeChatData['message']['text'];
      session = Session(sessionId: sessionId);
      session.connectToSession();
      MojoMessage message = MojoMessage(
          hasAudio: false,
          messagePk: homeChatData['message_pk'],
          text: homeChatData['message']['text']);
      message.audioManager = AudioManager(getAudioFile: message.getVoice);
      session.messages.add(message);
      _initialized = true;
    } catch (e) {
      logger.severe('Error initializing HomeChat: $e');
      inError = true;
      initialMessageHeader = "Something went wrong";
      initialMessageBody = "Error BODY";
    }
  }

  Future<void> terminate() async {
    // call backend so that it can pre-shot the next message
    try {
      post(service: 'home_chat', body: {});
    } catch (e) {
      logger.severe('Error terminating HomeChat: $e');
    }
  }

  Future<void> refresh() async {
    try {
      if (refreshing || !_initialized) return;
      _refreshing = true;
      //await session.loadMoreMessages(nMessages: 10, loadOlder: false);
      _refreshing = false;
    } catch (e) {
      logger.severe('Error refreshing HomeChat: $e');
    }
  }
}
