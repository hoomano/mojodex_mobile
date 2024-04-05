import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/tasks/task.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/models/workflows/workflow.dart';

import '../serializable_data_item.dart';
import '../workflows/user_worklow_execution.dart';

class UserTask extends SerializableDataItem with HttpCaller {
  // Logger
  final Logger logger = Logger('UserTask');

  /// Task to which userTask is associated
  late Task task;

  /// Getter is userTask enabled
  bool _enabled = false;
  bool get enabled => _enabled;

  @override
  UserTask.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    pk = data['user_task_pk'];
    _enabled = data['enabled'];
    bool isWorkflow = data['task_type'] == 'workflow';
    task = isWorkflow ? Workflow.fromJson(data) : Task.fromJson(data);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_task_pk': pk,
      'enabled': _enabled,
      ...task.toJson(),
    };
  }

  Future<UserTaskExecution?> newExecution(
      {int? userTaskExecutionFk,
      required Function onPaymentError,
      String? placeholderHeader,
      String? placeholderBody}) async {
    Map? userTaskExecutionData =
        await _putNewExecution(userTaskExecutionFk: userTaskExecutionFk);
    if (userTaskExecutionData == null) return null;
    if (userTaskExecutionData.containsKey("error") &&
        userTaskExecutionData["error"] == "no_purchase") {
      onPaymentError();
      return null;
    }
    List<dynamic> jsonInputsData = userTaskExecutionData["json_input"];
    // turn to List<Map<String, dynamic>>
    List<Map<String, dynamic>> jsonInputs = jsonInputsData
        .map((dynamic jsonInput) => jsonInput as Map<String, dynamic>)
        .toList();
    UserTaskExecution userTaskExecution = UserTaskExecution(
      userTaskExecutionPk: userTaskExecutionData["user_task_execution_pk"],
      userTaskPk: pk!,
      jsonInputs: jsonInputs,
      sessionId: userTaskExecutionData["session_id"],
      actions: userTaskExecutionData["actions"],
      editActions: userTaskExecutionData["text_edit_actions"],
      placeholderHeader: placeholderHeader,
      placeholderBody: placeholderBody,
    );
    return userTaskExecution;
  }

  Future<Map<String, dynamic>?> _putNewExecution(
      {int? userTaskExecutionFk}) async {
    try {
      Map<String, dynamic> body = {"user_task_pk": pk!};
      if (userTaskExecutionFk != null)
        body["user_task_execution_fk"] = userTaskExecutionFk;

      return await put(
          service: "user_task_execution", body: body, returnError: true);
    } catch (e) {
      logger.shout("Error in userTaskExecution exception: $e");
      return null;
    }
  }

  Future<UserWorkflowExecution?> newWorkflowExecution() async {
    Map<String, dynamic>? userWorkflowExecutionData = await _putNewExecution();
    if (userWorkflowExecutionData == null) return null;
    List<dynamic> jsonInputsData = userWorkflowExecutionData["json_input"];
    // turn to List<Map<String, dynamic>>
    List<Map<String, dynamic>> jsonInputs = jsonInputsData
        .map((dynamic jsonInput) => jsonInput as Map<String, dynamic>)
        .toList();
    UserWorkflowExecution userWorkflowExecution = UserWorkflowExecution(
        userWorkflowExecutionPk:
            userWorkflowExecutionData["user_task_execution_pk"],
        userWorkflowPk: pk!,
        inputs: jsonInputs,
        sessionId: userWorkflowExecutionData["session_id"],
        workflow: task as Workflow);
    return userWorkflowExecution;
  }
}
