import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../models/session/messages/audio_manager.dart';
import '../../../speaker.dart';

class VoiceMessageAudioWaveForm extends StatelessWidget {
  static final double height = 40;
  // Logger
  final Logger logger = Logger('VoiceMessageAudioWaveForm');

  final AudioManager audioManager;

  final bool m4aFileInvalid;
  final Color widgetColor;
  final Color backgroundColor;
  final Color liveColor;

  VoiceMessageAudioWaveForm(
      {super.key,
      required this.audioManager,
      required this.m4aFileInvalid,
      required this.widgetColor,
      required this.backgroundColor,
      required this.liveColor});

  /// this function is called when the Play/Pause button is press
  Future<void> onButtonPlayPauseTap() async {
    try {
      await Speaker().pausePlay(audioManager);
    } on Exception catch (e) {
      logger.shout("onButtonPlayPauseTap : Exception : $e");
    }
  }

  late double messageAudioWaveFormWidth;

  double _calculateVoiceMessageWidth(BuildContext context) {
    // This calculation is due to the fact that the package we use,
    // uses a fixed size that must be passed to it. So I have to
    // do the calculations by hand on the size it will have available
    // to display.
    // and this widget is displayed in the case of a task or in free discussion.
    // 80% of the screen - the cumulative padding of the components of which
    // plus its own padding (139) - 16 due to the wrapping tile
    // the extra component when you spot is selected.
    // all / 5 to leave 5px width for each sample to be displayed
    double width = MediaQuery.of(context).size.width;
    double mainContainerSize = width * 0.8;

    // play button size + button margin + divider + divider padding
    // + main container margin
    double globalPaddingLeft = 139;

    // number of bar that contains the voice message
    return (mainContainerSize - globalPaddingLeft - ds.Spacing.mediumPadding);
  }

  void _extractWaveForm(BuildContext context) {
    int noOfSamples = messageAudioWaveFormWidth ~/ 5;
    audioManager.extractWaveForm(noOfSamples);
  }

  @override
  Widget build(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    messageAudioWaveFormWidth = _calculateVoiceMessageWidth(context);

    if (!audioManager.waveFormExtracted) {
      _extractWaveForm(context);
      return SizedBox(
        height: height,
        child: Align(
          alignment: Alignment.center,
          child: LinearProgressIndicator(
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(widgetColor)),
        ),
      );
    }
    return Row(
      children: [
        IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onButtonPlayPauseTap,
            icon: audioManager.playerState.isPlaying
                ? Icon(Icons.pause, color: widgetColor)
                : Icon(Icons.play_arrow, color: widgetColor)),
        Container(
          width: 1,
          height: height,
          margin:
              const EdgeInsets.symmetric(horizontal: ds.Spacing.smallPadding),
        ),
        Builder(builder: (context) {
          if (m4aFileInvalid) {
            return Text(
                labelsProvider.getText(key: "errorMessages.m4aFileInvalid"),
                style: const TextStyle(color: Colors.amber));
          }
          double maxValue = 8;
          List<double> data = audioManager.audioController.waveformData;
          if (data.isNotEmpty) {
            double divider = data.reduce(max);
            if (divider != 0) maxValue = 1 / data.reduce(max);
          }
          return AudioFileWaveforms(
              size: Size(messageAudioWaveFormWidth, height),
              playerController: audioManager.audioController,
              padding: const EdgeInsets.only(right: ds.Spacing.smallPadding),
              animationCurve: Curves.easeIn,
              backgroundColor: Colors.white,
              animationDuration: const Duration(milliseconds: 500),
              playerWaveStyle: PlayerWaveStyle(
                  scaleFactor: maxValue * 15,
                  liveWaveColor: liveColor,
                  fixedWaveColor: widgetColor),
              enableSeekGesture: true,
              waveformType: WaveformType.fitWidth);
        }),
      ],
    );
  }
}
