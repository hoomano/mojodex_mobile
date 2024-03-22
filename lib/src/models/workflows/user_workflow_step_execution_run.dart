/*import 'package:mojodex_mobile/src/models/http_caller.dart';

class UserWorkflowStepExecutionRun with HttpCaller {
  late int pk;
  late Map<String, dynamic> parameter;
  bool started = false;
  bool validated = false;
  List<Map<String, dynamic>>? result;

  UserWorkflowStepExecutionRun({required this.pk});

  UserWorkflowStepExecutionRun.fromJson(Map<String, dynamic> data) {
    pk = data['user_workflow_step_execution_run_pk'];
    parameter = data['parameter'];
  }

  Map<String, dynamic> toJson() {
    return {'user_workflow_execution_step_run_pk': pk};
  }

  bool start() {
    if (started && result == null) {
      return false; // already started, socketio message received twice
    }
    started = true;
    result = null;
    validated = false;
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
      "user_workflow_step_execution_run_pk": pk,
      'validated': userValidation
    };
    Map<String, dynamic>? response =
        await post(service: "user_workflow_step_execution_run", body: body);
    if (response != null) {
      validated = userValidation;
      return true;
    }
    return false;
  }
}*/
