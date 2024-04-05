import 'package:mojodex_mobile/src/models/workflows/workflow_step.dart';

import '../tasks/task.dart';

class Workflow extends Task {
  late List<WorkflowStep> steps;

  @override
  Workflow.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    steps = (data['steps'] as List)
        .map((step) => WorkflowStep.fromJson(step))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'task_pk': pk,
      'task_name': name,
      'task_description': description,
      'task_icon': icon,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}
