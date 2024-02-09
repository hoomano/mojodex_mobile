import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/microphone.dart';

import '../../../speaker.dart';
import '../../user/user.dart';

typedef Downloader = Future<String?> Function();

class AudioManager extends ChangeNotifier {
  // Logger
  final Logger logger = Logger('AudioManager');

  /// Audio controller for this message
  final PlayerController audioController = PlayerController();

  Downloader getAudioFile;

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _initializing = false;

  bool _waveFormExtracted = false;
  bool get waveFormExtracted => _waveFormExtracted;

  bool _errorWithAudioFile = false;
  bool get errorWithAudioFile => _errorWithAudioFile;

  PlayerState get playerState => audioController.playerState;

  late String filename;

  void onPlayerStateChanged(PlayerState state) {}

  AudioManager({required this.getAudioFile});

  Future<void> initialize({bool playWhenInitialized = false}) async {
    if (_initialized || _initializing || _errorWithAudioFile) return;
    _initializing = true;
    audioController.onPlayerStateChanged.listen((PlayerState state) {
      onPlayerStateChanged(state);
      notifyListeners();
    });

    // if message is not current:
    String? filename = await getAudioFile();
    if (filename == null) {
      logger.shout("🔴 No audio file found");
      _errorWithAudioFile = true;
      _initializing = false;
      notifyListeners();
      return;
    }
    this.filename = filename;
    // download audio file from backend and prepare player
    await _preparePlayer();
    _initialized = true;
    _initializing = false;

    notifyListeners();
    if (playWhenInitialized && User().vocalMessageAutoPlay) {
      start();
    }
  }

  Future<void> _preparePlayer() async {
    try {
      await audioController.preparePlayer(
          path: filename, shouldExtractWaveform: false);
      return;
    } catch (e) {
      logger.shout('unable to play audio file: $filename: $e');
      _errorWithAudioFile = true;
    }
  }

  Future<void> extractWaveForm(int noOfSamples) async {
    try {
      List<double>? data = await audioController.extractWaveformData(
          path: filename, noOfSamples: noOfSamples);
      audioController.waveformData.clear();
      audioController.waveformData.addAll(data);
      _waveFormExtracted = true;
      notifyListeners();
    } catch (e) {
      logger.shout('Unable to extract audio waves: $filename: $e');
      _errorWithAudioFile = true;
    }
  }

  Future<void> pause() async {
    await audioController.pausePlayer();
  }

  Future<void> start() async {
    if (!Microphone().isRecording) {
      Speaker().currentPlayingAudioManager = this;
      await audioController.startPlayer(finishMode: FinishMode.pause);
    }
  }
}
