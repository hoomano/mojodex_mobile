import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/session/socketio_connector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../microphone.dart';

class VoiceChatBar extends StatefulWidget {
  final Function(String audioFilePath) onSubmit;
  final Function() onClickOnServiceInterrupted;

  final double? width;
  final String filename;
  final bool microAvailable;

  const VoiceChatBar(
      {super.key,
      required this.onSubmit,
      required this.onClickOnServiceInterrupted,
      required this.filename,
      this.width,
      required this.microAvailable});

  @override
  State<StatefulWidget> createState() => VoiceChatBarState();
}

class VoiceChatBarState extends State<VoiceChatBar> {
  Timer? pressTimer;
  bool longPress = false;
  Duration longPressDuration = const Duration(milliseconds: 500);
  ValueNotifier<bool> willBeDeleted = ValueNotifier(false);

  Widget serviceInterruption() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: GestureDetector(
            onTap: () => widget.onClickOnServiceInterrupted(),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: ds.DesignColor.grey.grey_5),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.error_outline,
                      color: ds.DesignColor.status.warning)),
            ),
          ),
        ),
      ),
    );
  }

  Widget micRequestPermission() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: GestureDetector(
            onTap: () {
              Microphone()
                  .requestPermission()
                  .then((status) => setState(() {}));
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: ds.DesignColor.grey.grey_5),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.mic_rounded,
                      color: ds.DesignColor.status.warning)),
            ),
          ),
        ),
      ),
    );
  }

  Widget micPermissionDeny() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: GestureDetector(
            onTap: () => openAppSettings(),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: ds.DesignColor.grey.grey_5),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.mic_off_outlined,
                      color: ds.DesignColor.grey.grey_9)),
            ),
          ),
        ),
      ),
    );
  }

  Widget micRecording(Microphone mic, bool longPress) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder(
          valueListenable: willBeDeleted,
          builder: (context, willBeDelete, _) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return Row(
              children: [
                SizedBox(
                  height: 50,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ds.DesignColor.status.error),
                        child: Padding(
                            padding:
                                const EdgeInsets.all(ds.Spacing.smallPadding),
                            child: Icon(
                                willBeDelete
                                    ? Icons.delete_forever_outlined
                                    : Icons.delete_outline_sharp,
                                color: ds.DesignColor.white)),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ds.Spacing.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                            visible: willBeDelete,
                            child: Text('release to undo...',
                                style: TextStyle(
                                    color: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? ds.DesignColor.grey.grey_1
                                        : ds.DesignColor.grey.grey_7))),
                        Expanded(
                          child: ValueListenableBuilder<int>(
                              valueListenable: scaleFactor,
                              builder: (context, scaleFactor, _) {
                                return AudioWaveforms(
                                  enableGesture: true,
                                  size: Size(
                                      (widget.width ??
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) -
                                          (!longPress ? 135 : 95),
                                      50),
                                  recorderController: mic.recorderController,
                                  waveStyle: WaveStyle(
                                      waveColor: themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_1
                                          : ds.DesignColor.grey.grey_9,
                                      extendWaveform: true,
                                      showMiddleLine: false,
                                      scaleFactor: scaleFactor.toDouble()),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: willBeDelete
                                        ? ds.DesignColor.status.error
                                        : themeProvider.themeMode ==
                                                ThemeMode.dark
                                            ? ds.DesignColor.grey.grey_5
                                            : ds.DesignColor.grey.grey_1,
                                  ),
                                );
                              }),
                        ),
                      ],
                    )),
                Visibility(
                  visible: !longPress,
                  child: SizedBox(
                    height: 50,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ds.DesignColor.primary.dark),
                          child: const Padding(
                              padding: EdgeInsets.all(ds.Spacing.smallPadding),
                              child: Icon(Icons.send, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget micStandbye() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: ds.DesignColor.primary.main),
            child: const Padding(
                padding: EdgeInsets.all(ds.Spacing.smallPadding),
                child: Icon(Icons.mic, color: ds.DesignColor.white)),
          ),
        ),
      ),
    );
  }

  Widget microUnavailable({bool isDark = false}) {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? ds.DesignColor.grey.grey_5
                    : ds.DesignColor.grey.grey_1),
            child: Padding(
                padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                child: Icon(Icons.mic_off, color: ds.DesignColor.grey.grey_7)),
          ),
        ),
      ),
    );
  }

  Widget sessionTerminated() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: ds.DesignColor.grey.grey_5),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.done, color: ds.DesignColor.status.success)),
          ),
        ),
      ),
    );
  }

  void onTapDown(PointerDownEvent detail, Microphone mic) {
    pressTimer = Timer(longPressDuration, () => onLongTap(detail.position.dx));
  }

  void onTapUp(PointerUpEvent detail, Microphone mic) {
    if (!longPress) {
      onTap(
        detail.position.dx,
      );
      return;
    }
    onLongTapUp(detail.position.dx);
  }

  void onLongTapUp(double posX) async {
    if (!Microphone().isRecording) return;
    pressTimer = null;
    longPress = false;
    if (posX < 100) {
      Microphone().cancelRecord();
      return;
    }
    String? filepath = await Microphone().stopRecord();
    widget.onSubmit(filepath!);
  }

  void onTap(double posX) async {
    pressTimer?.cancel();
    pressTimer = null;

    if (!Microphone().isRecording) {
      willBeDeleted.value = false;
      Microphone().record(filename: widget.filename).then((value) {});
      return;
    } else if (!Microphone().isRecording) {
      Microphone().cancelRecord().then((value) => onTap(posX));
    }
    if (posX < 100 && Microphone().isRecording) {
      Microphone().cancelRecord();
    } else if (posX > MediaQuery.of(context).size.width - 80 &&
        Microphone().isRecording) {
      String? filepath = await Microphone().stopRecord();
      widget.onSubmit(filepath!);
    }
  }

  void onLongTap(double posX) {
    pressTimer = null;
    if (!Microphone().isRecording) {
      longPress = true;
      Microphone().record(filename: widget.filename);
      return;
    } else if (!Microphone().isRecording) {
      Microphone().cancelRecord().then((value) {
        onLongTap(posX);
      });
    }
  }

  void onMove(PointerMoveEvent detail) {
    if (detail.position.dx < 100) {
      willBeDeleted.value = true;
      return;
    }
    willBeDeleted.value = false;
  }

  /// [scaleFactor] define the scale of the wave form in the [AudioWaveforms] widget
  /// it is calculated based on the max value of the wave form
  /// it is calculated every 500ms
  /// it is reset to 20 when the user stop recording
  /// [scaleFactorTimer] is the timer that trigger the recalculation of the [scaleFactor]
  /// it is canceled when the user stop recording
  ValueNotifier<int> scaleFactor = ValueNotifier(20);
  Timer? scaleFactorTimer;

  /// [autoCalibrateVoice] is the function that trigger the recalculation of the [scaleFactor]
  void autoCalibrateVoice(RecorderState status, Microphone mic) {
    if (status != RecorderState.recording) {
      scaleFactor.value = 20;
      scaleFactorTimer?.cancel();
      scaleFactorTimer = null;
      return;
    }
    scaleFactorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mic.recorderController.waveData.isEmpty) return;
      // disable autoScale factor after a moment to protect against slow perf
      if (mic.recorderController.waveData.length > 500) {
        scaleFactorTimer?.cancel();
        scaleFactorTimer = null;
        return;
      }
      double reduceMax = mic.recorderController.waveData.reduce(max);
      if (reduceMax < 0.08) return;
      scaleFactor.value = ((0.8 / reduceMax) * 20).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return StreamBuilder<ConnectionStatus>(
        // rebuild at each connection status change
        stream: SocketioConnector().connectionStatusStream,
        builder: (context, snapshot) {
          return SizedBox(
            height: 50,
            child: Consumer<Microphone>(builder: (context, mic, child) {
              autoCalibrateVoice(mic.recorderState, mic);
              if (mic.isDeny) {
                return micPermissionDeny();
              } else if (!mic.isAvailable) {
                return micRequestPermission();
              }
              if (widget.microAvailable == true) {
                return microUnavailable(
                    isDark: themeProvider.themeMode == ThemeMode.dark);
              }
              if (SocketioConnector().connectionStatus ==
                  ConnectionStatus.connected) {
                return Listener(
                  onPointerUp: (detail) => onTapUp(detail, mic),
                  onPointerDown: (detail) => onTapDown(detail, mic),
                  onPointerMove: (detail) => onMove(detail),
                  child: AnimatedContainer(
                    alignment: Alignment.centerRight,
                    width: mic.isRecording
                        ? (widget.width ?? MediaQuery.of(context).size.width) -
                            8
                        : 54,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: mic.isRecording
                            ? micRecording(mic, longPress)
                            : micStandbye()),
                  ),
                );
              } else {
                return serviceInterruption();
              }
            }),
          );
        });
  }
}
