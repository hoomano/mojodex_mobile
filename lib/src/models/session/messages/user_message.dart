import 'package:mojodex_mobile/src/models/session/messages/message.dart';

class UserMessage extends Message {
  /// Message's creation date
  DateTime creationDate = DateTime.now();

  /// If the message is an approval to task_tool_execution, related task_tool_execution_pk
  int? taskToolExecutionPk;

  /// If the message is a request for text_edit_action, related text_edit_action_pk
  int? textEditActionPk;

  UserMessage(
      {super.hasAudio = false,
      super.sender = MessageSender.user,
      this.taskToolExecutionPk,
      this.textEditActionPk,
      String? text}) {
    isCurrentProcessingUserMessage = true;
    acked = false;
    if (text != null) {
      this.text = text;
      hasTranscript = true;
    }
  }

  UserMessage.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  void ack() {
    acked = true;
    notifyListeners();
  }

  void receivedText(String text, int messagePk) {
    this.messagePk = messagePk;
    this.text = text;
    hasTranscript = true;
    notifyListeners();
  }

  void failEmission(String errorMessage) {
    emissionFailed = true;
    notifyListeners();
    put(service: 'error', body: {'error': errorMessage, 'notify_admin': true});
  }

  void retry() {
    emissionFailed = false;
    notifyListeners();
  }
}
