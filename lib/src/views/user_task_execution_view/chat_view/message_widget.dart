import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/session/messages/audio_manager.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/message_container.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/voice_message_audio.dart';
import 'package:provider/provider.dart';

import '../../../models/session/messages/message.dart';
import 'message_failed_emission.dart';

class MessageWidget extends StatelessWidget {
  final bool autoPlay;
  final Function() onResubmit;
  final Function(String) correctSpell;
  final Message message;
  final bool streaming;

  const MessageWidget({
    super.key,
    this.autoPlay = true,
    required this.onResubmit,
    required this.correctSpell,
    required this.streaming,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MessageContainer(
        alignment:
            message.sentByUser ? Alignment.centerRight : Alignment.centerLeft,
        hasLeading: message.sentByUser,
        child: message.emissionFailed
            ? MessageFailed(onResubmit: onResubmit)
            : ChangeNotifierProvider<AudioManager?>.value(
                value: message.audioManager,
                child: VoiceMessageAudio(
                    message: message,
                    correctSpell: correctSpell,
                    streaming: streaming)));
  }
}
