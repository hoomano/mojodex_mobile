import 'package:mojodex_mobile/src/models/session/messages/message.dart';

class MojoMessage extends Message {
  String? suggestedTaskFirstMessage;
  String? suggestedTaskPlaceholderQuestion;
  String? suggestedTaskPlaceholderInstruction;

  MojoMessage(
      {super.sender = MessageSender.agent,
      required super.hasAudio,
      super.autoPlay = true,
      super.taskToolExecutionPk = null,
      required int messagePk,
      required String text,
      this.suggestedTaskFirstMessage,
      this.suggestedTaskPlaceholderQuestion,
      this.suggestedTaskPlaceholderInstruction}) {
    this.messagePk = messagePk;
    hasTranscript = true;
    this.text = text;
  }

  MojoMessage.fromJson(Map<String, dynamic> data) : super.fromJson(data);
}
