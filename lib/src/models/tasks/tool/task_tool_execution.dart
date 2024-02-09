import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/task_tool_query.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/tool.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';

class TaskToolExecution {
  // Logger
  final Logger logger = Logger('TaskToolExecution');

  /// primary key of the object in the backend
  late int taskToolExecutionPk;

  late Tool tool;

  late List<TaskToolQuery> queries;

  TaskToolExecution.fromJson(Map<String, dynamic> data) {
    taskToolExecutionPk = data['task_tool_execution_pk']!;
    tool = UserTaskExecution.availableTools
        .firstWhere((element) => element.label == data['tool_name']!);
    queries = List<TaskToolQuery>.from(
        data['queries'].map((x) => TaskToolQuery.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    return {
      'task_tool_execution_pk': taskToolExecutionPk,
      'tool_name': tool.label,
      'queries': queries.map((e) => e.toJson()).toList(),
    };
  }
}
