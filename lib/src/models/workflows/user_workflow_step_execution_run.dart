import 'package:mojodex_mobile/src/models/http_caller.dart';

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

  Future<bool> validate() async {
    Map<String, dynamic> body = {
      "user_workflow_step_execution_run_pk": pk,
      'validated': true
    };
    Map<String, dynamic>? response =
        await post(service: "user_workflow_step_execution_run", body: body);
    print("👉 validate response: $response");
    if (response != null) {
      validated = true;
      print("👉 validated: $validated");
      return true;
    }
    return false;
  }
}
