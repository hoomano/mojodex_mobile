import 'session/messages/audio_manager.dart';

class ProducedText {
  /// the produced text pk associated to this task execution
  int? producedTextPk;

  /// the produced text version pk associated to this task execution
  int? producedTextVersionPk;

  /// the produced text title associated to this task execution
  String? title;

  /// the produced associated to this task execution
  String? production;

  AudioManager? audioManager;

  ProducedText(
      {this.producedTextPk,
      this.producedTextVersionPk,
      this.title,
      this.production,
      this.audioManager});
}
