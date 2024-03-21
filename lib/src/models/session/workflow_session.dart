import 'package:mojodex_mobile/src/models/session/session.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution_run.dart';

import 'messages/message.dart';
import 'messages/user_message.dart';

class WorkflowSession extends Session {
  WorkflowSession(
      {required super.sessionId,
      required int userWorkflowExecutionPk,
      required this.onUserWorkflowRunExecutionStarted,
      required this.onUserWorkflowRunExecutionEnded,
      required this.onUserWorkflowStepExecutionInitialized,
      required this.onUserWorkflowStepExecutionReset}) {
    _userWorkflowExecutionPk = userWorkflowExecutionPk;
  }

  late int _userWorkflowExecutionPk;

  final Function(int stepExecutionPk, int runExecutionPk)
      onUserWorkflowRunExecutionStarted;
  final Function(int stepExecutionPk, int runExecutionPk,
      List<Map<String, dynamic>> result) onUserWorkflowRunExecutionEnded;
  final Function(int stepExecutionPk, List<UserWorkflowStepExecutionRun> runs)
      onUserWorkflowStepExecutionInitialized;
  final Function(int stepExecutionPk, int previousStepExecutionPk)
      onUserWorkflowStepExecutionReset;

  void onWorkflowRunStartedCallback(dynamic data) {
    onUserWorkflowRunExecutionStarted(
        data["step_execution_fk"], data["user_workflow_step_execution_run_pk"]);
  }

  void onWorkflowRunEndedCallback(dynamic data) {
    // data["result"] is a List<dynamic>
    List<Map<String, dynamic>> result = data["result"]
        .map<Map<String, dynamic>>((run) => Map<String, dynamic>.from(run))
        .toList();
    onUserWorkflowRunExecutionEnded(data["step_execution_fk"],
        data["user_workflow_step_execution_run_pk"], result);
  }

  void onWorkflowStepExecutionInitializedCallback(dynamic data) {
    onUserWorkflowStepExecutionInitialized(
        data["user_workflow_step_execution_pk"],
        data['runs']
            .map<UserWorkflowStepExecutionRun>(
                (run) => UserWorkflowStepExecutionRun.fromJson(run))
            .toList());
  }

  void onWorkflowStepExecutionResetCallback(dynamic data) {
    onUserWorkflowStepExecutionReset(data["user_workflow_step_execution_pk"],
        data["previous_step_execution_pk"]);
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
