import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/session/messages/audio_manager.dart';

class Speaker {
  // Logger
  final Logger logger = Logger('Speaker');

  // Unique instance of the class
  static final Speaker _instance = Speaker.privateConstructor();

  // Private constructor of the class, called once when the class is created
  Speaker.privateConstructor();

  factory Speaker() => _instance;

  AudioManager? currentPlayingAudioManager;

  Future<void> pausePlay(AudioManager audioManager) async {
    if (audioManager.playerState.isPlaying) {
      logger.info("pausePlay: audioPlayer isPlaying, let's pause it");
      await audioManager.pause();
      currentPlayingAudioManager = null;
    } else {
      logger.info("pausePlay:: audioManager isPaused, let's play it");
      if (currentPlayingAudioManager?.playerState == PlayerState.playing ||
          currentPlayingAudioManager?.playerState == PlayerState.stopped) {
        logger.info("pausePlay:: SOMEONE ELSE isPlaying, let's pause it");
        await currentPlayingAudioManager!.pause();
      }
      currentPlayingAudioManager = audioManager;
      logger.info("currentPlayingAudioManager changed");
      await audioManager.start();
    }
  }
}
