import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/tasks/user_task_execution.dart';
import '../../models/user/user.dart';

class UserTaskExecutionCard extends StatefulWidget {
  final UserTaskExecution userTaskExecution;
  final DismissDirectionCallback onDismissed;

  late String formattedTimeAgo;

  UserTaskExecutionCard(
      {required this.userTaskExecution, required this.onDismissed, Key? key})
      : super(key: key) {
    Duration timeAgo;
    if (userTaskExecution.startDate != null) {
      timeAgo = DateTime.now().difference(userTaskExecution.startDate!);
      // if time ago < 1min => now
      // else if time ago < 1h => Xmin ago
      // else if <= 1d => Xh ago
      // else if <= 1 week 3first letters of day + hh:mm
      // else yyyy-mm-dd
      if (timeAgo.inMinutes < 1) {
        formattedTimeAgo = "now";
      } else if (timeAgo.inHours < 1) {
        formattedTimeAgo = "${timeAgo.inMinutes}min ago";
      } else if (timeAgo.inDays < 1) {
        formattedTimeAgo = "${timeAgo.inHours}h ago";
      } else if (timeAgo.inDays < 7) {
        // name of the weekday
        String weekdayFirstLetters = DateFormat('EEEE')
            .format(userTaskExecution.startDate!)
            .substring(0, 3);
        formattedTimeAgo =
            "$weekdayFirstLetters ${userTaskExecution.startDate!.hour.toString().padLeft(2, '0')}:${userTaskExecution.startDate!.minute.toString().padLeft(2, '0')}";
      } else {
        formattedTimeAgo =
            "${userTaskExecution.startDate!.year.toString()}-${userTaskExecution.startDate!.month.toString().padLeft(2, '0')}-${userTaskExecution.startDate!.day.toString().padLeft(2, '0')}";
      }
    } else {
      formattedTimeAgo = "";
    }
  }

  @override
  State<UserTaskExecutionCard> createState() => _UserTaskExecutionCardState();
}

class _UserTaskExecutionCardState extends State<UserTaskExecutionCard> {
  Color backgroundCardColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Dismissible(
      onUpdate: (details) {
        if (details.progress > 0 && backgroundCardColor != Colors.red) {
          setState(() {
            backgroundCardColor = Colors.red;
          });
        }
        if (details.progress == 0 &&
            backgroundCardColor != Colors.transparent) {
          setState(() {
            backgroundCardColor = Colors.transparent;
          });
        }
      },
      key: Key(widget.userTaskExecution.pk.toString()),
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: ds.Spacing.largePadding),
              child: const Icon(Icons.delete, color: ds.DesignColor.white),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: ds.Spacing.largePadding),
              child: const Icon(Icons.delete, color: ds.DesignColor.white),
            ),
          ],
        ),
      ),
      onDismissed: widget.onDismissed,
      child: Container(
        color: backgroundCardColor,
        child: Card(
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          color: themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_7
              : ds.DesignColor.grey.grey_1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: ds.Pills.primary(
              type: ds.PillsType.fill,
              alignment: AlignmentDirectional.centerStart,
              visibility: widget.userTaskExecution.nNotReadTodos > 0,
              child: Padding(
                padding: const EdgeInsets.only(left: ds.Spacing.mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: ds.Spacing.smallPadding),
                          child: Text(
                            "${User().userTasksList.getParticularItemSync(widget.userTaskExecution.userTaskPk)?.task.icon ?? ""} "
                            "${widget.userTaskExecution.title ?? User().userTasksList.getParticularItemSync(widget.userTaskExecution.userTaskPk)?.task.name ?? ""}",
                            style: TextStyle(
                                fontSize: ds.TextFontSize.body2,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_3
                                    : ds.DesignColor.grey.grey_9),
                          )),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: ds.Spacing.smallPadding),
                      child: Row(
                        children: [
                          Text(
                            "${widget.userTaskExecution.startDate == null ? '' : widget.formattedTimeAgo}"
                            "${widget.userTaskExecution.producedText == null ? "" : " ✓"}",
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_7),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
