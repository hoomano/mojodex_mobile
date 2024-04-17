import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/plan_view.dart';
import 'package:mojodex_mobile/src/views/settings_view/settings_view.dart';
import 'package:mojodex_mobile/src/views/skeletons/skeleton_item.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../app_router.dart';
import '../../models/session/messages/user_message.dart';
import '../../models/tasks/user_task.dart';
import '../../models/tasks/user_task_execution.dart';
import '../../models/user/user.dart';
import '../user_task_execution_view/user_task_execution_view.dart';

class TaskCard extends StatefulWidget {
  final UserTask userTask;

  // Those are useful for predefined actions
  final String? firstMessageText;
  final UserTaskExecution? currentUserTaskExecution;
  final Function onProcessingChanged;
  final Function(int)? onNavigateToUserTaskExecutionView;
  final int? userTaskExecutionFk;
  final Function onBackFromPlanPage;
  final bool pushWithReplacement;
  final bool navigateAsGo;
  final String? userTaskExecutionPlaceholderHeader;
  final String? userTaskExecutionPlaceholderBody;

  const TaskCard(
      {required this.userTask,
      required this.onProcessingChanged,
      required this.onBackFromPlanPage,
      required this.pushWithReplacement,
      this.navigateAsGo = true,
      this.onNavigateToUserTaskExecutionView,
      this.firstMessageText,
      this.currentUserTaskExecution,
      this.userTaskExecutionFk,
      this.userTaskExecutionPlaceholderHeader,
      this.userTaskExecutionPlaceholderBody,
      Key? key})
      : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Opacity(
      opacity: widget.userTask.enabled ? 1.0 : 0.5,
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
                    if (!widget.userTask.enabled) {
                      context.push(
                          '/${SettingsView.routeName}/${PlanView.routeName}');
                      widget.onBackFromPlanPage();
                    } else {
                      widget.onProcessingChanged();
                      setState(() {
                        processing = true;
                      });
                      UserTaskExecution? newUserTaskExecution =
                          await widget.userTask.newExecution(
                        userTaskExecutionFk: widget.userTaskExecutionFk,
                        onPaymentError: () async {
                          await User().roleManager.refreshRole();
                          context.push(
                              '/${SettingsView.routeName}/${PlanView.routeName}');
                        },
                        placeholderHeader:
                            widget.userTaskExecutionPlaceholderHeader,
                        placeholderBody:
                            widget.userTaskExecutionPlaceholderBody,
                      );
                      if (newUserTaskExecution == null) {
                        widget.onProcessingChanged();
                        setState(() {
                          processing = false;
                        });
                        return;
                      }

                      UserMessage? userMessage;
                      if (widget.firstMessageText != null) {
                        userMessage = UserMessage(
                            text: widget.firstMessageText!, hasAudio: false);
                      }
                      UserTaskExecutionView userTaskExecutionView =
                          UserTaskExecutionView(
                              userTaskExecution: newUserTaskExecution,
                              initialTab: UserTaskExecutionView.chatTabName,
                              firstMessageToSend: userMessage,
                              refreshUserTaskExecution: false);

                      if (widget.onNavigateToUserTaskExecutionView != null) {
                        widget.onNavigateToUserTaskExecutionView!(
                            newUserTaskExecution.pk!);
                      }
                      if (widget.pushWithReplacement) {
                        AppRouter().goRouter.pushReplacement(
                            '/${UserTaskExecutionsListView.routeName}/${newUserTaskExecution.pk}',
                            extra: userTaskExecutionView);
                      } else {
                        setState(() {
                          processing = false;
                        });
                        if (widget.navigateAsGo) {
                          AppRouter().goRouter.go(
                              '/${UserTaskExecutionsListView.routeName}/${newUserTaskExecution.pk}',
                              extra: userTaskExecutionView);
                        } else {
                          AppRouter().goRouter.push(
                              '/${UserTaskExecutionsListView.routeName}/${newUserTaskExecution.pk}',
                              extra: userTaskExecutionView);
                        }
                      }
                    }
                  },
                  isThreeLine: true,
                  minVerticalPadding: ds.Spacing.mediumPadding,
                  leading: Text(widget.userTask.task.icon,
                      style: const TextStyle(fontSize: ds.TextFontSize.h2)),
                  title: Text(widget.userTask.task.name,
                      style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_7,
                          fontSize: ds.TextFontSize.h5)),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: ds.Spacing.smallPadding),
                    child: Text(widget.userTask.task.description,
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
