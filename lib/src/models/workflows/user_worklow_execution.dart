// import collection.dart
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/serializable_data_item.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution.dart';
import 'package:mojodex_mobile/src/models/workflows/workflow.dart';
import 'package:mojodex_mobile/src/models/workflows/workflow_step.dart';

import '../produced_text.dart';
import '../session/workflow_session.dart';

class UserWorkflowExecution extends SerializableDataItem
    with HttpCaller, ChangeNotifier {
  //late final Session session; Todo: new type of session ?
  late final int userWorkflowPk;
  List<UserWorkflowStepExecution> stepExecutions = [];

  late Workflow workflow;

  /// the produced text delivered by this task execution
  ProducedText? producedText;

  late List<Map<String, dynamic>>
      inputs; // for now only keys => 1 key = 1 text field

  /// The date and time the workflow was started
  DateTime? startDate;

  late WorkflowSession session;

  bool _waitingForValidation = false;
  bool get waitingForValidation => _waitingForValidation;
// used if userTaskExecution is created from the app
  UserWorkflowExecution(
      {required int userWorkflowExecutionPk,
      required this.userWorkflowPk,
      required this.inputs,
      required String sessionId,
      required this.workflow})
      : super(userWorkflowExecutionPk) {
    session = WorkflowSession(
      sessionId: sessionId,
      userWorkflowExecutionPk: pk!,
      onNewWorkflowStepExecution: _newStepExecution,
      onUserWorkflowStepExecutionEnded: _stepExecutionEnded,
      onUserWorkflowStepExecutionInvalidated: _stepExecutionInvalidated,
      onUserWorkflowReceivedProducedText: (producedText) {
        if (this.producedText != null) return;
        this.producedText = producedText;
        notifyListeners();
      },
    );
  }

  @override
  UserWorkflowExecution.fromJson(Map<String, dynamic> data, this.workflow)
      : super.fromJson(data) {
    pk = data['user_task_execution_pk'];
    userWorkflowPk = data['user_task_pk'];

    startDate =
        data['start_date'] != null ? DateTime.parse(data['start_date']) : null;

    session = WorkflowSession(
      sessionId: data['session_id'],
      userWorkflowExecutionPk: pk!,
      onNewWorkflowStepExecution: _newStepExecution,
      onUserWorkflowStepExecutionEnded: _stepExecutionEnded,
      onUserWorkflowStepExecutionInvalidated: _stepExecutionInvalidated,
      onUserWorkflowReceivedProducedText: (producedText) {
        if (this.producedText != null) return;
        this.producedText = producedText;
        notifyListeners();
      },
    );
  }

  void _stepExecutionInvalidated(int stepExecutionPk) {
    // is stepExecutionPk in stepExecutions ?
    UserWorkflowStepExecution? stepExecution =
        stepExecutions.firstWhereOrNull((step) => step.pk == stepExecutionPk);
    if (stepExecution != null) {
      // remove stepExecution from stepExecutions
      stepExecutions.remove(stepExecution);
      _waitingForValidation = false;
      notifyListeners();
    }
  }

  void _newStepExecution(
      int stepExecutionPk, int stepFk, Map<String, dynamic> parameter) {
    print("🟢 _newStepExecution");
    UserWorkflowStepExecution? stepExecution =
        stepExecutions.firstWhereOrNull((step) => step.pk == stepExecutionPk);
    print("🟢 stepExecution: $stepExecution");
    if (stepExecution == null) {
      print("🟢 stepExecution == null");
      // else, message already received
      print("==> WORKFLOW: $workflow");
      WorkflowStep step =
          workflow.steps.firstWhere((step) => step.pk == stepFk);
      print("🟢 step: $step");
      stepExecutions.add(UserWorkflowStepExecution(
        pk: stepExecutionPk,
        parameter: parameter,
        step: step,
      ));
      print("🟢 stepExecutions: $stepExecutions");
      _waitingForValidation = false;
      print("🟢 notifyListeners()");
      notifyListeners();
    }
  }

  void _stepExecutionEnded(
      int stepExecutionPk, List<Map<String, dynamic>> result) {
    bool ended = stepExecutions
        .firstWhere((step) => step.pk == stepExecutionPk)
        .end(result);
    if (ended) {
      _waitingForValidation = true;
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

  Future<Map<String, dynamic>?> start() async {
    try {
      Map<String, dynamic> body = {
        "user_task_execution_pk": pk!,
        'inputs': inputs
      };
      Map<String, dynamic>? response =
          await post(service: "user_task_execution_run", body: body);
      if (response != null) {
        startDate = DateTime.now();
      }
      notifyListeners();
      return response;
    } catch (e) {
      return null;
    }
  }

  bool refreshing = false;

  /// Refresh the user workflow execution data that could have evolved while user was not on its view:
  Future<void> refresh() async {
    if (refreshing) return;
    refreshing = true;
    notifyListeners();

    //resubmit old messages in error
    session.resubmitOldMessagesInError();
    List<Future> futures = [
      session.loadMoreMessages(nMessages: 10, loadOlder: false),
      _refreshData(),
    ];
    await Future.wait(futures);
    refreshing = false;
    notifyListeners();
  }

  Future<void> _refreshData() async {
    Map<String, dynamic>? userWorkflowExecutionData = await get(
        service: "user_workflow_execution",
        params: "user_workflow_execution_pk=$pk");
    if (userWorkflowExecutionData != null) {
      updateFromJson(userWorkflowExecutionData);
    }
  }

  Future<void> updateFromJson(Map<String, dynamic> data) async {
    // TODO
  }

  /// Whether the user workflow execution has been deleted by the user
  bool _deletedByUser = false;
  bool get deletedByUser => _deletedByUser;
}
