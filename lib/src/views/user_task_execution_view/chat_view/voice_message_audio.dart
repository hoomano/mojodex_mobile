import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/session/messages/audio_manager.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/voice_message_audio_wave_form.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/voice_message_check.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/voice_message_text.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/session/messages/message.dart';

class VoiceMessageAudio extends StatelessWidget {
  // Logger
  final Logger logger = Logger('VoiceMessageAudio');

  final Message message;
  final Function(String) correctSpell;
  final bool streaming;

  VoiceMessageAudio({
    super.key,
    required this.message,
    required this.correctSpell,
    required this.streaming,
  }) {
    if (message.hasAudio) {
      message.audioManager!
          .initialize(playWhenInitialized: message.autoPlay)
          .then((value) => message.autoPlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Color messageColor = message.sentByUser
        ? ds.DesignColor.primary.dark
        : themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_7
            : ds.DesignColor.grey.grey_1;

    Color textColor = message.sentByUser
        ? ds.DesignColor.white
        : themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_1
            : ds.DesignColor.grey.grey_9;

    Color notReadAudioColor = message.sentByUser
        ? ds.DesignColor.white
        : themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_1
            : ds.DesignColor.grey.grey_3;

    Color readAudioColor = message.sentByUser
        ? themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_3
            : ds.DesignColor.grey.grey_9
        : themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_5
            : ds.DesignColor.grey.grey_9;

    Widget downloading = Padding(
      padding: const EdgeInsets.all(ds.Spacing.smallPadding),
      child: LinearProgressIndicator(
          backgroundColor: messageColor,
          valueColor:
              AlwaysStoppedAnimation<Color>(ds.DesignColor.grey.grey_1)),
    );
    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: messageColor),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(vertical: ds.Spacing.base),
        child: Consumer<AudioManager?>(builder:
            (BuildContext context, AudioManager? audioManager, Widget? child) {
          Widget audioWaveForm;
          if (!message.hasAudio || message.audioManager!.errorWithAudioFile) {
            return VoiceMessageText(
                text: message.text,
                textColor: textColor,
                correctSpell: correctSpell,
                streaming: streaming);
          }
          if (!message.audioManager!.initialized) {
            audioWaveForm = downloading;
          } else {
            audioWaveForm = VoiceMessageAudioWaveForm(
              audioManager: message.audioManager!,
              m4aFileInvalid: message.audioManager!.errorWithAudioFile,
              widgetColor: notReadAudioColor,
              backgroundColor: messageColor,
              liveColor: readAudioColor,
            );
          }

          return Column(
            children: [
              message.hasTranscript
                  ? VoiceMessageText(
                      text: message.text,
                      textColor: textColor,
                      correctSpell: correctSpell,
                      streaming: streaming)
                  : const SizedBox.shrink(),
              audioWaveForm,
              if (message.sentByUser) VoiceMessageCheck(active: message.acked)
            ],
          );
        }));
  }
}
