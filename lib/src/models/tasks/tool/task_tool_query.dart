import 'package:logging/logging.dart';

class TaskToolQuery {
  // Logger
  final Logger logger = Logger('TaskToolQuery');

  ///primary key of the object in the backend
  late int taskToolQueryPk;

  /// Parameters used for querying the tool
  late Map<String, dynamic> query;

  /// Result of the tool
  List<dynamic>? result;

  TaskToolQuery.fromJson(Map<String, dynamic> data) {
    taskToolQueryPk = data['task_tool_query_pk']!;
    query = data['query']!;
    result = data['result'];
  }

  Map<String, dynamic> toJson() {
    return {
      'task_tool_query_pk': taskToolQueryPk,
      'query': query,
      'result': result,
    };
  }
}
