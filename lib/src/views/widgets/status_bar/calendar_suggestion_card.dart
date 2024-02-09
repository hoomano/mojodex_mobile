import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/status_bar/calendar_suggestion.dart';
import '../../../models/user/user.dart';
import '../../new_user_task_execution/task_card.dart';
import 'love_reaction_button.dart';

class CalendarSuggestionCard extends StatelessWidget {
  final Function onHide;
  final Function onTerminate;
  final Function onTaskCardSelected;
  final Function onBackFromPlanPage;

  const CalendarSuggestionCard(
      {required this.onHide,
      required this.onTerminate,
      required this.onTaskCardSelected,
      required this.onBackFromPlanPage,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            onHide();
          },
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ds.Spacing.mediumPadding),
              child: Column(
                children: [
                  SizedBox(
                    height: ds.TextFontSize.h3 * 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CalendarSuggestion().suggestionEmoji,
                          style: TextStyle(
                              fontSize: ds.TextFontSize.h3,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.white
                                  : ds.DesignColor.grey.grey_9),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: ds.Spacing.smallPadding),
                          child: ds.DesignIcon.chevronDown(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.white
                                  : ds.DesignColor.grey.grey_9,
                              size: 20),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CalendarSuggestion().suggestionTitle,
                      style: TextStyle(
                          fontSize: ds.TextFontSize.h3,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.white
                              : ds.DesignColor.grey.grey_9),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: ds.Spacing.smallPadding),
                      child: Text(CalendarSuggestion().suggestionBody,
                          style: TextStyle(
                              fontSize: ds.TextFontSize.body2,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.white
                                  : ds.DesignColor.grey.grey_9)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        CalendarSuggestion().userTaskToPropose != null
            ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TaskCard(
                            userTask: CalendarSuggestion().userTaskToPropose!,
                            onProcessingChanged: () {
                              onTaskCardSelected();
                            },
                            pushWithReplacement:
                                User().userTaskExecutionsHistory.isEmpty,
                            onNavigateToUserTaskExecutionView:
                                (int userTaskExecutionPk) {
                              CalendarSuggestion().answer(
                                  userTaskExecutionPk: userTaskExecutionPk);
                              onTerminate();
                              onTaskCardSelected();
                            },
                            onBackFromPlanPage: onBackFromPlanPage),
                      ),
                      SizedBox(
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              onTerminate();
                            },
                            icon: ds.DesignIcon.closeSM(
                                color: ds.DesignColor.grey.grey_3, size: 40),
                          ),
                        ),
                      )
                    ],
                  ),
                  /*SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          onTerminate();
                        },
                        icon: ds.DesignIcon.closeSM(
                            color: ds.DesignColor.grey.grey_3, size: 40),
                      ),
                    ),
                  )*/
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 50,
                  //width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LoveReactionButton(
                        onLove: () async {
                          await CalendarSuggestion().answer(userReacted: true);
                          onTerminate();
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          onTerminate();
                        },
                        icon: ds.DesignIcon.closeSM(
                            color: ds.DesignColor.grey.grey_3, size: 40),
                      )
                    ],
                  ),
                ),
              )
      ],
    );
  }
}
