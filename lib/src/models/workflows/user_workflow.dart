import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/workflows/user_worklow_execution.dart';
import 'package:mojodex_mobile/src/models/workflows/workflow.dart';

import '../serializable_data_item.dart';

class UserWorkflow extends SerializableDataItem with HttpCaller {
  // Logger
  final Logger logger = Logger('UserWorkflow');

  /// Workflow to which userWorkflow is associated
  late Workflow workflow;

  UserWorkflow({required int userWorkflowPk, required this.workflow})
      : super(userWorkflowPk);

  @override
  UserWorkflow.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    pk = data['user_workflow_pk'];
    workflow = Workflow.fromJson(data);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_workflow_pk': pk,
      ...workflow.toJson(),
    };
  }

  Future<UserWorkflowExecution?> newExecution() async {
    Map<String, dynamic>? userWorkflowExecutionData = await _putNewExecution();
    if (userWorkflowExecutionData == null) return null;
    //List<dynamic> jsonInputsData = userWorkflowExecutionData["json_input"];
    // turn to List<Map<String, dynamic>>
    //List<Map<String, dynamic>> jsonInputs = jsonInputsData
    //  .map((dynamic jsonInput) => jsonInput as Map<String, dynamic>)
    //.toList();
    UserWorkflowExecution userWorkflowExecution =
        UserWorkflowExecution.fromJson(userWorkflowExecutionData);
    return userWorkflowExecution;
  }

  Future<Map<String, dynamic>?> _putNewExecution() async {
    try {
      Map<String, dynamic> body = {"user_workflow_pk": pk!};
      return await put(service: "user_workflow_execution", body: body);
    } catch (e) {
      logger.shout("Error in userWorkflowExecution exception: $e");
      return null;
    }
  }
}
