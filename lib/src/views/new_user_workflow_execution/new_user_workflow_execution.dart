import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflows_list.dart';
import 'package:mojodex_mobile/src/views/new_user_workflow_execution/workflow_card.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../drawer/app_drawer.dart';
import '../skeletons/skeleton_list.dart';

class NewUserWorkflowExecution extends StatefulWidget {
  static String routeName = "new_user_workflow_execution";
  @override
  State<NewUserWorkflowExecution> createState() =>
      _NewUserWorkflowExecutionState();
}

class _NewUserWorkflowExecutionState extends State<NewUserWorkflowExecution> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      //drawer: User().userWorkflowExecutionsHistory.isEmpty ? AppDrawer() : null,
      drawer: AppDrawer(),
      appBarTitle: "New user workflow execution",
      //labelsProvider.getText(key: "newUserWorkflowExecution.appBarTitle"),
      safeAreaOverflow: true,
      body: AbsorbPointer(
        absorbing: processing,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
              child: Text(
                "🧰 Let's start a new workflow",
                //labelsProvider.getText(key: "newUserWorkflowExecution.title"),
                style: TextStyle(
                    fontSize: ds.TextFontSize.h3,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? ds.DesignColor.white
                        : ds.DesignColor.grey.grey_9),
              ),
            ),
            Consumer<UserWorkflowsList>(
                builder: (context, userWorkflowsList, child) {
              return Expanded(
                child: userWorkflowsList.loading
                    ? SkeletonList()
                    : ListView(
                        children: userWorkflowsList
                            .map((userWorkflow) => WorkflowCard(
                                userWorkflow: userWorkflow,
                                onProcessingChanged: () {
                                  setState(() {
                                    processing = !processing;
                                  });
                                },
                                onBackFromPlanPage: () {
                                  setState(
                                      () {}); // to rebuild after user_workflows reload
                                },
                                pushWithReplacement: false
                                //pushWithReplacement: User().userWorkflowExecutionsHistory.isNotEmpty
                                ))
                            .toList()),
              );
            }),
          ],
        ),
      ),
      bottomBarWidget: Consumer<UserWorkflowsList>(
          builder: (context, userWorkflowsList, child) {
        return Visibility(
            visible: userWorkflowsList.refreshing,
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
