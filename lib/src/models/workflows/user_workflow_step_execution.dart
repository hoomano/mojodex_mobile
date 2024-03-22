import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/workflows/workflow_step.dart';

class UserWorkflowStepExecution with HttpCaller {
  late int pk;
  late WorkflowStep step;
  bool validated = false;
  List<Map<String, dynamic>>? result;
  late Map<String, dynamic> parameter;

  UserWorkflowStepExecution(
      {required this.pk, required this.step, required this.parameter});

  UserWorkflowStepExecution.fromJson(Map<String, dynamic> data) {
    pk = data['user_workflow_step_execution_pk'];
    step = WorkflowStep(pk: data['workflow_step_pk'], name: data['step_name']);
    validated = data['validated'];
    parameter = data['parameter'];
    result = data['result'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_workflow_step_execution_pk': pk,
      'workflow_step_pk': step.pk,
      'step_name': step.name,
      'validated': validated,
      'parameter': parameter,
      'result': result
    };
  }

  bool end(List<Map<String, dynamic>> result) {
    if (this.result != null) return false;
    this.result = result;
    return true;
  }

  Future<bool> validate() async {
    return await _send_backend_validation(true);
  }

  Future<bool> invalidate() async {
    return await _send_backend_validation(false);
  }

  Future<bool> _send_backend_validation(bool userValidation) async {
    Map<String, dynamic> body = {
      "user_workflow_step_execution_pk": pk,
      'validated': userValidation
    };
    Map<String, dynamic>? response =
        await post(service: "user_workflow_step_execution", body: body);
    if (response != null) {
      validated = userValidation;
      return true;
    }
    return false;
  }
}
