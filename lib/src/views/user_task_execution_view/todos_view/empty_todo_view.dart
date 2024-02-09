import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';

class EmptyTodoForUserTaskExecution extends StatelessWidget {
  final UserTaskExecution userTaskExecution;
  EmptyTodoForUserTaskExecution({required this.userTaskExecution, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.largePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userTaskExecution.workingOnTodos
                  ? labelsProvider.getText(
                      key: "userTaskExecution.todosTab.workingOnTodosEmoji")
                  : labelsProvider.getText(
                      key: "userTaskExecution.todosTab.notWorkingOnTodosEmoji"),
              style: TextStyle(
                  fontSize: ds.TextFontSize.h4,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? const Color.fromARGB(255, 0, 0, 1)
                      : ds.DesignColor.grey.grey_9),
              textAlign: TextAlign.start,
            ),
            Text(
              userTaskExecution.workingOnTodos
                  ? labelsProvider.getText(
                      key:
                          "userTaskExecution.todosTab.workingOnTodosTitleMessage")
                  : labelsProvider.getText(
                      key:
                          "userTaskExecution.todosTab.notWorkingOnTodosTitleMessage"),
              style: TextStyle(
                  fontSize: ds.TextFontSize.h4,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_1
                      : ds.DesignColor.grey.grey_9),
            ),
            ds.Space.verticalSmall,
            Text(
              userTaskExecution.workingOnTodos
                  ? labelsProvider.getText(
                      key:
                          "userTaskExecution.todosTab.workingOnTodosBodyMessage")
                  : labelsProvider.getText(
                      key:
                          "userTaskExecution.todosTab.notWorkingOnTodosBodyMessage"),
              style: TextStyle(
                  fontSize: ds.TextFontSize.body1,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_3
                      : ds.DesignColor.grey.grey_5),
            ),
          ],
        ),
      ),
    );
  }
}
