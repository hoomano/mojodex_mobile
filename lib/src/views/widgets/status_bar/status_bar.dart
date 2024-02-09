import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mojodex_mobile/src/views/widgets/status_bar/calendar_suggestion_card.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../app_router.dart';
import '../../../models/calendar_manager/calendar_manager.dart';
import '../../../models/language/system_language.dart';
import '../../../models/status_bar/calendar_suggestion.dart';
import '../../../models/status_bar/status_bar_data.dart';
import '../../settings_view/calendar_settings_view/calendarSettingsView.dart';
import '../../settings_view/settings_view.dart';

class StatusBar extends StatefulWidget {
  final Function(double) onGetSize;
  final Function onTerminate;
  final Function onTaskCardSelected;
  const StatusBar(
      {required this.onGetSize,
      required this.onTerminate,
      required this.onTaskCardSelected,
      Key? key})
      : super(key: key);

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  bool _enableButton = true;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ds.Spacing.smallPadding),
      child: Container(
        child: ValueListenableBuilder<calendarSuggestionStatus>(
            valueListenable: CalendarSuggestion().status,
            builder: (context, calendarSuggestionStatus status, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onGetSize(context.size!.height);
                if ((status == calendarSuggestionStatus.error ||
                        status == calendarSuggestionStatus.isEmpty) &&
                    StatusBarData().displayed.value) {
                  widget.onTerminate();
                }
              });

              if (status == calendarSuggestionStatus.off ||
                  status == calendarSuggestionStatus.isEmpty) {
                return Container();
              }

              if (status == calendarSuggestionStatus.noCalendarAccess) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(StatusBarData().text ?? "",
                          style: TextStyle(
                              fontSize: ds.TextFontSize.body2,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_1
                                  : ds.DesignColor.grey.grey_9)),
                    ),
                    if (_enableButton)
                      ds.Button.fill(
                          text: labelsProvider.getText(
                              key: "calendar.statusBarGrantButton"),
                          onPressed: () async {
                            bool accepted =
                                await CalendarManager().askCalendarPermission();
                            if (accepted) {
                              setState(() {
                                StatusBarData().displayed.value = false;
                              });
                              await AppRouter().goRouter.push(
                                  '/${SettingsView.routeName}/${CalendarSettingsView.routeName}');
                              CalendarSuggestion().init();
                            } else {
                              setState(() {
                                _enableButton = false;
                                StatusBarData().text = labelsProvider.getText(
                                    key: "calendar.accessDenied");
                              });
                              await Future.delayed(Duration(seconds: 5));
                              StatusBarData().displayed.value = false;
                            }
                          }),
                  ],
                );
              }

              if (status == calendarSuggestionStatus.ready) {
                return StatusBarData().expanded
                    ? CalendarSuggestionCard(
                        onHide: () {
                          setState(() {
                            StatusBarData().expanded = false;
                          });
                        },
                        onTerminate: widget.onTerminate,
                        onTaskCardSelected: widget.onTaskCardSelected,
                        onBackFromPlanPage: () {
                          setState(() {});
                        })
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            StatusBarData().expanded = true;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: SizedBox(
                            height: ds.TextFontSize.h3 * 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ds.Space.horizontalLarge,
                                Expanded(
                                  child: Text(StatusBarData().text!,
                                      style: TextStyle(
                                          fontSize: ds.TextFontSize.body2,
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.dark
                                              ? ds.DesignColor.grey.grey_1
                                              : ds.DesignColor.grey.grey_9)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: ds.Spacing.smallPadding),
                                  child: ds.DesignIcon.chevronRight(
                                      color: themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.white
                                          : ds.DesignColor.grey.grey_9,
                                      size: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
              }
              // if status == waiting
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: LoadingAnimationWidget.waveDots(
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_1
                            : ds.DesignColor.grey.grey_9,
                        size: 30,
                      )),
                  ds.Space.horizontalLarge,
                  Expanded(
                    child: Text(StatusBarData().text!,
                        style: TextStyle(
                            fontSize: ds.TextFontSize.body2,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_1
                                : ds.DesignColor.grey.grey_9)),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
