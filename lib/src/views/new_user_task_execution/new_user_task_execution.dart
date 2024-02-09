import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/tasks/user_tasks_list.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/task_card.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/user/user.dart';
import '../drawer/app_drawer.dart';
import '../skeletons/skeleton_list.dart';

class NewUserTaskExecution extends StatefulWidget {
  static String routeName = "new_user_task_execution";
  @override
  State<NewUserTaskExecution> createState() => _NewUserTaskExecutionState();
}

class _NewUserTaskExecutionState extends State<NewUserTaskExecution> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      drawer: User().userTaskExecutionsHistory.isEmpty ? AppDrawer() : null,
      appBarTitle:
          labelsProvider.getText(key: "newUserTaskExecution.appBarTitle"),
      safeAreaOverflow: true,
      body: AbsorbPointer(
        absorbing: processing,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
              child: Text(
                labelsProvider.getText(key: "newUserTaskExecution.title"),
                style: TextStyle(
                    fontSize: ds.TextFontSize.h3,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? ds.DesignColor.white
                        : ds.DesignColor.grey.grey_9),
              ),
            ),
            Consumer<UserTasksList>(builder: (context, userTasksList, child) {
              return Expanded(
                child: userTasksList.loading
                    ? SkeletonList()
                    : ListView(
                        children: userTasksList
                            .map((userTask) => TaskCard(
                                userTask: userTask,
                                onProcessingChanged: () {
                                  setState(() {
                                    processing = !processing;
                                  });
                                },
                                onBackFromPlanPage: () {
                                  setState(
                                      () {}); // to rebuild after user_tasks reload
                                },
                                pushWithReplacement:
                                    User().userTaskExecutionsHistory.isNotEmpty))
                            .toList()),
              );
            }),
          ],
        ),
      ),
      bottomBarWidget:
          Consumer<UserTasksList>(builder: (context, userTasksList, child) {
        return Visibility(
            visible: userTasksList.refreshing,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ds.Spacing.smallPadding,
                  vertical: ds.Spacing.mediumPadding),
              child: LinearProgressIndicator(
                color: ds.DesignColor.primary.main,
                backgroundColor: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_7
                    : ds.DesignColor.grey.grey_3,
              ),
            ));
      }),
    );
  }
}
