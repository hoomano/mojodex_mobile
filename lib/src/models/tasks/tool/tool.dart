import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/task_tool_query.dart';

abstract class Tool {
  String name;

  // Label corresponds to the name of the tool in the backend
  String label;
  Tool({required this.name, required this.label});

  // method to be overridden by subclasses to return resultWidget
  Widget getResultWidget(
      {required BuildContext context, required TaskToolQuery taskToolQuery}) {
    return Container();
  }
}
