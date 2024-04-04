import 'package:mojodex_mobile/src/models/session/session.dart';

import '../produced_text.dart';
import 'messages/message.dart';
import 'messages/user_message.dart';

class WorkflowSession extends Session {
  WorkflowSession(
      {required super.sessionId,
      required int userWorkflowExecutionPk,
      required this.onNewWorkflowStepExecution,
      required this.onUserWorkflowStepExecutionEnded,
      required this.onUserWorkflowStepExecutionInvalidated,
      required this.onUserWorkflowReceivedProducedText}) {
    _userWorkflowExecutionPk = userWorkflowExecutionPk;
  }

  late int _userWorkflowExecutionPk;

  final Function(
          int stepExecutionPk, int stepFk, Map<String, dynamic> parameter)
      onNewWorkflowStepExecution;
  final Function(int stepExecutionPk, List<Map<String, dynamic>> result)
      onUserWorkflowStepExecutionEnded;
  final Function(int stepExecutionPk) onUserWorkflowStepExecutionInvalidated;
  final Function(ProducedText producedText) onUserWorkflowReceivedProducedText;

  void onNewWorkflowStepExecutionCallback(dynamic data) {
    onNewWorkflowStepExecution(data["user_workflow_step_execution_pk"],
        data['workflow_step_pk'], data["parameter"]);
  }

  void onWorkflowStepExecutionInvalidatedCallback(dynamic data) {
    onUserWorkflowStepExecutionInvalidated(
        data["user_workflow_step_execution_pk"]);
  }

  void onWorkflowStepExecutionEndedCallback(dynamic data) {
    // data["result"] is a List<dynamic>
    List<Map<String, dynamic>> result = data["result"]
        .map<Map<String, dynamic>>((run) => Map<String, dynamic>.from(run))
        .toList();
    onUserWorkflowStepExecutionEnded(
        data["user_workflow_step_execution_pk"], result);
  }

  void onWorkflowExecutionProducedTextCallback(dynamic data) {
    ProducedText producedText = ProducedText(
        producedTextPk: data['produced_text_pk'],
        producedTextVersionPk: data['produced_text_version_pk'],
        title: data['produced_text_title'],
        production: data['produced_text'],
        audioManager: messages.isNotEmpty ? messages.first.audioManager : null);
    onUserWorkflowReceivedProducedText(producedText);
  }

  @override
  Map<String, dynamic> userMessageFormData(UserMessage message, String origin) {
    Map<String, dynamic> formData = super.userMessageFormData(message, origin);
    formData['user_workflow_execution_pk'] = _userWorkflowExecutionPk;
    return formData;
  }

  @override
  Future<Map<String, dynamic>?> sendUserMessage(UserMessage message,
      {int retry = 3, String origin = 'workflow'}) async {
    return super.sendUserMessage(message, retry: retry, origin: origin);
  }

  @override
  bool dropMessage(int messagePk) {
    // Following is for avoiding receving duplicate messages if backend did not received ack which happens with slow network
    // - _messages.isEmpty is for dealing with the case where you were chatting, went back to the task list (there session.messages is cleared idk why) and then went back to the chat
    // here messages are empty but you are still receiving missed acked messages
    // - getMessageFromPk(messagePk) != null is for dealing with the case where you are chatting live
    if (getMessageFromPk(messagePk, MessageSender.agent) != null) {
      logger.fine("Already received message => dropping");
      return true; // maybe the backend missed a ack
    }
    return false;
  }
}
