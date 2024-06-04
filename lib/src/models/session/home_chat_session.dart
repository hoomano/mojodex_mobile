import 'dart:async';

import 'package:mojodex_mobile/src/models/session/session.dart';

import 'messages/audio_manager.dart';
import 'messages/mojo_message.dart';

class HomeChatSession extends Session {
  HomeChatSession({required super.sessionId});

  final StreamController<String?> _welcomeMessageTokenController =
      StreamController.broadcast();
  Stream<String?> get welcomeMessageTokenStream =>
      _welcomeMessageTokenController.stream;

  String? onGoingMojoMessageHeader;
  String? onGoingMojoMessageBody;

  void onWelcomeMessageToken(dynamic data) {
    if (data is Map && data.containsKey('text')) {
      _welcomeMessageTokenController.add(data['text']);
      onGoingMojoMessageHeader = data['header'];
      onGoingMojoMessageBody = data['body'];
    }
  }

  void onWelcomeMessage(dynamic data) {
    int messagePk = data['message_pk'];
    MojoMessage message = mojoMessageFromMap(data, messagePk);

    if (message.hasAudio) {
      message.audioManager = AudioManager(getAudioFile: message.getVoice);
    }
    addMojoMessageToLocalList(message);
    onGoingMojoMessage = null;
    notifyListeners();
    return;
  }
}
