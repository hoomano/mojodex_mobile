import 'package:flutter/material.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../models/tasks/tool/task_tool_execution.dart';

class TaskToolExecutionWidget extends StatefulWidget {
  final TaskToolExecution taskToolExecution;
  final int index;
  final int total;
  TaskToolExecutionWidget(
      {required this.taskToolExecution,
      required this.index,
      required this.total,
      Key? key})
      : super(key: key);

  @override
  State<TaskToolExecutionWidget> createState() =>
      _TaskToolExecutionWidgetState();
}

class _TaskToolExecutionWidgetState extends State<TaskToolExecutionWidget> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: ds.DesignColor.grey.grey_3,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _open = !_open;
                  });
                },
                child: Row(
                  children: [
                    ds.DesignIcon.searchMagnifyingGlass(
                        color: ds.DesignColor.grey.grey_5,
                        size: ds.TextFontSize.body1),
                    Expanded(
                        child: Center(
                            child: Text(
                      "${widget.taskToolExecution.tool.name}${widget.total > 1 ? " - ${widget.index + 1}/${widget.total}" : ''}",
                      style: TextStyle(
                          color: ds.DesignColor.grey.grey_5,
                          fontSize: ds.TextFontSize.h6),
                    ))),
                    _open
                        ? ds.DesignIcon.chevronDown(
                            color: ds.DesignColor.grey.grey_3,
                            size: ds.TextFontSize.body1)
                        : ds.DesignIcon.chevronRight(
                            color: ds.DesignColor.grey.grey_3,
                            size: ds.TextFontSize.body1),
                  ],
                ),
              ),
              Visibility(
                  visible: _open,
                  child: Column(
                    children: [
                      ds.Space.verticalLarge
                    ]..addAll(widget.taskToolExecution.queries
                        .map((taskToolQuery) => Padding(
                              padding:
                                  const EdgeInsets.all(ds.Spacing.smallPadding),
                              child: widget.taskToolExecution.tool
                                  .getResultWidget(
                                      context: context,
                                      taskToolQuery: taskToolQuery),
                            ))
                        .toList()),
                  ))
            ],
          ),
        ));
  }
}
