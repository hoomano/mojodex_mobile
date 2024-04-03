import 'package:mojodex_mobile/src/models/workflows/workflow_step.dart';

class Workflow {
  late int pk;
  late String name;
  late String icon;
  late String definition;
  late List<WorkflowStep> steps;

  Workflow({required this.pk, required this.name});

  Workflow.fromJson(Map<String, dynamic> data) {
    pk = data['workflow_pk'];
    name = data['name_for_user'];
    icon = data['icon'];
    definition = data['definition_for_user'];
    steps = (data['steps'] as List)
        .map((step) => WorkflowStep.fromJson(step))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_pk': pk,
      'name_for_user': name,
      'icon': icon,
      'definition_for_user': definition,
      'steps': steps.map((step) => step.toJson()).toList()
    };
  }
}
