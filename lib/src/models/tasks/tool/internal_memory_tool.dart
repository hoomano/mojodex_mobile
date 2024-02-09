import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/task_tool_query.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/tool.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';

import '../../../../DS/design_system.dart' as ds;

class InternalMemoryTool extends Tool {
  InternalMemoryTool()
      : super(name: "Internal Memory Search Results", label: "internal_memory");

  @override
  Widget getResultWidget(
      {required BuildContext context,
      required TaskToolQuery taskToolQuery,
      int? index,
      int? total}) {
    //title is the concatenation of all taskToolQuery.query values (not keys)
    String title = "${taskToolQuery.query.values.join(" - ")}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: ds.TextFontSize.h6, fontWeight: FontWeight.bold),
        ),
        taskToolQuery.result == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: taskToolQuery.result!.map((result) {
                  String extractedInformation =
                      "- ${result['extracted_informations'].join('\n\n- ')}\n\n";
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(
                                "/${UserTaskExecutionsListView.routeName}/${result["user_task_execution_pk"]}");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: ds.Spacing.smallPadding),
                            child: Text(
                              "${result["task_icon"]} ${result['produced_text_title']}",
                              style: TextStyle(
                                  fontSize: ds.TextFontSize.body2,
                                  color: ds.DesignColor.primary.main),
                            ),
                          ),
                        ),
                        Text(extractedInformation)
                      ]);
                }).toList())
      ],
    );
  }
}
