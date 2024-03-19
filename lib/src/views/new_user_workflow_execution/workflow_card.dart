import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/plan_view.dart';
import 'package:mojodex_mobile/src/views/settings_view/settings_view.dart';
import 'package:mojodex_mobile/src/views/skeletons/skeleton_item.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../app_router.dart';
import '../../models/workflows/user_workflow.dart';
import '../../models/workflows/user_worklow_execution.dart';
import '../workflows_view/user_workflow_execution_view.dart';

class WorkflowCard extends StatefulWidget {
  final UserWorkflow userWorkflow;

  // Those are useful for predefined actions
  final String? firstMessageText;
  final UserWorkflowExecution? currentUserWorkflowExecution;
  final Function onProcessingChanged;
  final Function(int)? onNavigateToUserWorkflowExecutionView;
  final int? userWorkflowExecutionFk;
  final Function onBackFromPlanPage;
  final bool pushWithReplacement;
  final bool navigateAsGo;
  final String? userWorkflowExecutionPlaceholderHeader;
  final String? userWorkflowExecutionPlaceholderBody;

  const WorkflowCard(
      {required this.userWorkflow,
      required this.onProcessingChanged,
      required this.onBackFromPlanPage,
      required this.pushWithReplacement,
      this.navigateAsGo = true,
      this.onNavigateToUserWorkflowExecutionView,
      this.firstMessageText,
      this.currentUserWorkflowExecution,
      this.userWorkflowExecutionFk,
      this.userWorkflowExecutionPlaceholderHeader,
      this.userWorkflowExecutionPlaceholderBody,
      Key? key})
      : super(key: key);

  @override
  State<WorkflowCard> createState() => _WorkflowCardState();
}

class _WorkflowCardState extends State<WorkflowCard> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Opacity(
      opacity: widget.userWorkflow.enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: ds.Spacing.smallPadding,
            horizontal: ds.Spacing.mediumPadding),
        child: Material(
          elevation: 3,
          color: themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_7
              : ds.DesignColor.grey.grey_1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: processing
              ? SkeletonCard()
              : ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  onTap: () async {
                    if (!widget.userWorkflow.enabled) {
                      context.push(
                          '/${SettingsView.routeName}/${PlanView.routeName}');
                      widget.onBackFromPlanPage();
                    } else {
                      widget.onProcessingChanged();
                      setState(() {
                        processing = true;
                      });
                      UserWorkflowExecution? newUserWorkflowExecution =
                          await widget.userWorkflow.newExecution();
                      if (newUserWorkflowExecution == null) {
                        widget.onProcessingChanged();
                        setState(() {
                          processing = false;
                        });
                        return;
                      }

                      UserWorkflowExecutionView userWorkflowExecutionView =
                          UserWorkflowExecutionView(
                        userWorkflowExecution: newUserWorkflowExecution,
                      );

                      if (widget.onNavigateToUserWorkflowExecutionView !=
                          null) {
                        widget.onNavigateToUserWorkflowExecutionView!(
                            newUserWorkflowExecution.pk!);
                      }
                      if (widget.pushWithReplacement) {
                        /* AppRouter().goRouter.pushReplacement(
                      '/${UserWorkflowExecutionsListView.routeName}/${newUserWorkflowExecution.pk}',
                      extra: userWorkflowExecutionView);*/
                      } else {
                        setState(() {
                          processing = false;
                        });
                        /* if (widget.navigateAsGo) {
                    AppRouter().goRouter.go(
                        '/${UserWorkflowExecutionsListView.routeName}/${newUserWorkflowExecution.pk}',
                        extra: userWorkflowExecutionView);
                  } else {
                    AppRouter().goRouter.push(
                        '/${UserWorkflowExecutionsListView.routeName}/${newUserWorkflowExecution.pk}',
                        extra: userWorkflowExecutionView);
                  }*/
                        AppRouter().goRouter.pushNamed(
                            UserWorkflowExecutionView.routeName,
                            extra: userWorkflowExecutionView);
                      }
                    }
                  },
                  isThreeLine: true,
                  minVerticalPadding: ds.Spacing.mediumPadding,
                  leading: Text(widget.userWorkflow.workflow.icon,
                      style: const TextStyle(fontSize: ds.TextFontSize.h2)),
                  title: Text(widget.userWorkflow.workflow.name,
                      style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_7,
                          fontSize: ds.TextFontSize.h5)),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: ds.Spacing.smallPadding),
                    child: Text(widget.userWorkflow.workflow.description,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_3
                                : ds.DesignColor.grey.grey_3,
                            fontSize: ds.TextFontSize.h6)),
                  ),
                ),
        ),
      ),
    );
  }
}
