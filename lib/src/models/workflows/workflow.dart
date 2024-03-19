class Workflow {
  late int pk;
  late String name;
  late String icon;
  late String description;

  Workflow({required this.pk, required this.name});

  Workflow.fromJson(Map<String, dynamic> data) {
    print(data);
    pk = data['workflow_pk'];
    name = data['name'];
    icon = data['icon'];
    description = data['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_pk': pk,
      'workflow_name': name,
      'icon': icon,
      'description': description,
    };
  }
}
