import 'package:mojodex_mobile/src/models/workflows/user_workflow_step.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution_run.dart';

class UserWorkflowStepExecution {
  late int pk;
  late WorkflowStep step;
  late List<UserWorkflowStepExecutionRun> runs;
  late bool initialized;
  late bool validated;
  List<Map<String, String>>? result;

  UserWorkflowStepExecution(
      {required this.pk,
      required this.step,
      required this.runs,
      required this.initialized,
      required this.validated});

  UserWorkflowStepExecution.fromJson(Map<String, dynamic> data) {
    pk = data['user_workflow_step_execution_pk'];
    step = WorkflowStep(pk: data['workflow_step_pk'], name: data['step_name']);
    initialized = data['initialized'];
    validated = data['validated'];
    runs = data['runs']
        .map<UserWorkflowStepExecutionRun>(
            (run) => UserWorkflowStepExecutionRun.fromJson(run))
        .toList();
    result = data['result'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_workflow_step_execution_pk': pk,
      'workflow_step_pk': step.pk,
      'step_name': step.name,
      'initialized': initialized,
      'validated': validated,
      'runs': runs.map((run) => run.toJson()).toList(),
      'result': result
    };
  }

  bool reset(int newStepExecutionPk) {
    if (pk != newStepExecutionPk) {
      pk = newStepExecutionPk;
      runs = [];
      initialized = false;
      return true;
    }
    return false;
  }

  bool startRun(int runExecutionPk) {
    UserWorkflowStepExecutionRun runToStart =
        runs.firstWhere((run) => run.pk == runExecutionPk);
    return runToStart.start();
  }

  void initialize(List<UserWorkflowStepExecutionRun> runs) {
    initialized = true;
    this.runs = runs;
  }

  bool endRun(int runExecutionPk, List<Map<String, dynamic>> result) {
    UserWorkflowStepExecutionRun runToEnd =
        runs.firstWhere((run) => run.pk == runExecutionPk);
    if (runToEnd.result != null) return false;
    runToEnd.result = result;
    return true;
  }
}
