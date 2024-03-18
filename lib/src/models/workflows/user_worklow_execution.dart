import 'package:flutter/cupertino.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/serializable_data_item.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution_run.dart';

import '../session/workflow_session.dart';

class UserWorkflowExecution extends SerializableDataItem
    with HttpCaller, ChangeNotifier {
  //late final Session session; Todo: new type of session ?
  late final int userWorkflowPk;
  late List<UserWorkflowStepExecution> stepExecutions;

  /// The date and time the workflow was started
  DateTime? startDate;

  late WorkflowSession session;

  UserWorkflowExecution(
      {required int userWorkflowExecutionPk,
      required this.userWorkflowPk,
      required String sessionId})
      : super(userWorkflowExecutionPk) {
    session = WorkflowSession(
        sessionId: sessionId,
        onUserWorkflowStepExecutionInitialized: _initializeStepExecution,
        onUserWorkflowRunExecutionStarted: _startRunExecution,
        onUserWorkflowRunExecutionEnded: _endRunExecution);
  }

  @override
  UserWorkflowExecution.fromJson(Map<String, dynamic> data)
      : super.fromJson(data) {
    pk = data['user_workflow_execution_pk'];
    userWorkflowPk = data['user_workflow_fk'];
    stepExecutions = data['steps']
        .map<UserWorkflowStepExecution>(
            (step) => UserWorkflowStepExecution.fromJson(step))
        .toList();
    startDate =
        data['start_date'] != null ? DateTime.parse(data['start_date']) : null;
    session = WorkflowSession(
        sessionId: data['session_id'],
        onUserWorkflowStepExecutionInitialized: _initializeStepExecution,
        onUserWorkflowRunExecutionStarted: _startRunExecution,
        onUserWorkflowRunExecutionEnded: _endRunExecution);
  }

  void _initializeStepExecution(
      int stepExecutionPk, List<UserWorkflowStepExecutionRun> runs) {
    UserWorkflowStepExecution stepToInitialize =
        stepExecutions.firstWhere((step) => step.pk == stepExecutionPk);
    if (stepToInitialize.initialized) return;
    stepToInitialize.initialize(runs);
    notifyListeners();
  }

  void _startRunExecution(int stepExecutionPk, int runExecutionPk) {
    bool started = stepExecutions
        .firstWhere((step) => step.pk == stepExecutionPk)
        .startRun(runExecutionPk);
    if (started) {
      // else, message already received
      notifyListeners();
    }
  }

  void _endRunExecution(int stepExecutionPk, int runExecutionPk,
      List<Map<String, dynamic>> result) {
    bool ended = stepExecutions
        .firstWhere((step) => step.pk == stepExecutionPk)
        .endRun(runExecutionPk, result);
    if (ended) {
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_workflow_execution_pk': pk,
      'user_workflow_fk': userWorkflowPk,
      'steps': stepExecutions.map((step) => step.toJson()).toList(),
      'start_date': startDate?.toIso8601String(),
      'session_id': session.sessionId
    };
  }

  Future<Map<String, dynamic>?> start(
      Map<String, dynamic> initialParameters) async {
    try {
      Map<String, dynamic> body = {
        "user_workflow_execution_pk": pk!,
        'initial_parameters': initialParameters
      };
      Map<String, dynamic>? response =
          await post(service: "user_workflow_execution", body: body);
      if (response != null) {
        startDate = DateTime.now();
      }
      notifyListeners();
      return response;
    } catch (e) {
      return null;
    }
  }
}
