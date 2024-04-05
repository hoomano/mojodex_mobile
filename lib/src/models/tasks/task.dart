import 'package:mojodex_mobile/src/models/serializable_data_item.dart';

class Task extends SerializableDataItem {
  /// The name of the task
  late String name;

  /// The description of the task
  late String description;

  /// The icon of the task
  late String icon;

  Task(
      {required int taskPk,
      required this.name,
      required this.description,
      required this.icon})
      : super(taskPk);

  @override
  Task.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    pk = data['task_pk'];
    name = data['task_name'];
    description = data['task_description'];
    icon = data['task_icon'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'task_pk': pk,
      'task_name': name,
      'task_description': description,
      'task_icon': icon
    };
  }
}
