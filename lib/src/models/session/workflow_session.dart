import 'package:mojodex_mobile/src/models/session/session.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution_run.dart';

class WorkflowSession extends Session {
  WorkflowSession(
      {required super.sessionId,
      required this.onUserWorkflowRunExecutionStarted,
      required this.onUserWorkflowRunExecutionEnded,
      required this.onUserWorkflowStepExecutionInitialized,
      required this.onUserWorkflowStepExecutionReset});

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
}
