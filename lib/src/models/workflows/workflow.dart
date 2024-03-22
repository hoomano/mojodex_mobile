import 'package:mojodex_mobile/src/models/workflows/workflow_step.dart';

class Workflow {
  late int pk;
  late String name;
  late String icon;
  late String description;
  late List<WorkflowStep> steps;

  Workflow({required this.pk, required this.name});

  Workflow.fromJson(Map<String, dynamic> data) {
    pk = data['workflow_pk'];
    name = data['name'];
    icon = data['icon'];
    description = data['description'];
    steps = (data['steps'] as List)
        .map((step) => WorkflowStep.fromJson(step))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_pk': pk,
      'name': name,
      'icon': icon,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList()
    };
  }
}
