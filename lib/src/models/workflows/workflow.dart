class Workflow {
  late int pk;
  late String name;

  Workflow({required this.pk, required this.name});

  Workflow.fromJson(Map<String, dynamic> data) {
    pk = data['workflow_pk'];
    name = data['workflow_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_pk': pk,
      'workflow_name': name,
    };
  }
}
