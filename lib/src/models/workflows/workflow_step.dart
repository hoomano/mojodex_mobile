class WorkflowStep {
  late int pk;
  late String name;

  WorkflowStep({required this.pk, required this.name});

  WorkflowStep.fromJson(Map<String, dynamic> data) {
    pk = data['workflow_step_pk'];
    name = data['step_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_step_pk': pk,
      'step_name': name,
    };
  }
}
