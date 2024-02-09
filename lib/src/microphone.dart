import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/speaker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'models/user/user.dart';

/// source
/// https://pub.dev/packages/speech_to_text/versions/4.0.0-nullsafety

/// this class is a singleton
/// it is used to manage the microphone
/// use it like this:
/// Microphone().initSpeechToText();
/// Microphone().listen(myCallback);
///
/// to force stop listening use:
/// Microphone().stopListening();
///
/// to check if the microphone is available use:
/// Microphone().microphoneAvailable
///
/// to check if the microphone is on use:
/// Microphone().microphoneOn
class Microphone extends ChangeNotifier {
  // TODO => why use ChangeNotifier?
  late final RecorderController _recorderController;

  String? _currentAudioFilePath;

  factory Microphone() => _instance;
  static final Microphone _instance = Microphone._privateConstructor();

  Microphone._privateConstructor() {
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..onRecorderStateChanged.listen((state) {
        notifyListeners();
        if (state.isRecording) {
          // The following line will enable the Android and iOS wakelock = keep the screen awake while recording.
          WakelockPlus.enable();
        } else if (state.isStopped) {
          // The next line disables the wakelock.
          WakelockPlus.disable();
        }
      });
  }

  RecorderController get recorderController {
    return _recorderController;
  }

  bool get isRecording {
    return _recorderController.isRecording;
  }

  RecorderState get recorderState {
    return _recorderController.recorderState;
  }

  bool _isAvailable = false;

  bool _isDeny = false;

  bool get isAvailable => _isAvailable;

  bool get isDeny => _isDeny;

  Future<void> init() async {
    _isAvailable = await Permission.microphone.isGranted;
    _isDeny = await Permission.microphone.isPermanentlyDenied;
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    _isAvailable = status.isGranted;
    _isDeny = status.isDenied;
    return _isAvailable;
  }

  Future<void> record({required String filename}) async {
    if (_recorderController.isRecording) return;
    await Speaker().currentPlayingAudioManager?.pause();
    _currentAudioFilePath = "${User().appDocPath}/$filename.m4a";
    await _recorderController.record(path: _currentAudioFilePath);
    notifyListeners();
  }

  /// force stop listening to the microphone
  Future<String?> stopRecord() async {
    if (!_recorderController.isRecording) return null;
    await _recorderController.stop();
    notifyListeners();
    return _currentAudioFilePath;
  }

  Future<void> cancelRecord() async {
    await _recorderController.stop();
    notifyListeners();
  }

  Widget builder(BuildContext context,
      {required Widget Function(
              BuildContext context, RecorderState status, Microphone mic)
          builder}) {
    final ValueNotifier<bool> updater = ValueNotifier(false);
    addListener(() => updater.value = !updater.value);
    return ValueListenableBuilder(
        valueListenable: updater,
        builder: (context, _, __) {
          return builder(context, _recorderController.recorderState, this);
        });
  }
}
