class WorkflowStep {
  late int pk;
  late String name;
  late String definition;

  WorkflowStep({required this.pk, required this.name});

  WorkflowStep.fromJson(Map<String, dynamic> data) {
    pk = data['workflow_step_pk'];
    name = data['step_name_for_user'];
    definition = data['step_definition_for_user'];
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_step_pk': pk,
      'step_name_for_user': name,
      'step_definition_for_user': definition
    };
  }
}
