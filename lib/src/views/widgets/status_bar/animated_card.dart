import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/status_bar/status_bar_data.dart';
import 'package:mojodex_mobile/src/views/widgets/status_bar/status_bar.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/user/user.dart';

class AnimatedStatusBar extends StatefulWidget {
  final Function onTaskCardSelected;
  String? name;
  AnimatedStatusBar({required this.onTaskCardSelected, this.name, Key? key})
      : super(key: key);

  @override
  State<AnimatedStatusBar> createState() => _AnimatedStatusBarState();
}

class _AnimatedStatusBarState extends State<AnimatedStatusBar> {
  final int _animationDurationMs = 500;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ValueListenableBuilder<bool>(
        valueListenable: User().userTaskExecutionsHistory.initialLoadDone,
        builder: (context, initialLoadDone, child) {
          return ValueListenableBuilder<bool>(
              valueListenable: StatusBarData().displayed,
              builder: (context, welcomeTextDisplayed, child) {
                return ValueListenableBuilder<double>(
                    valueListenable: StatusBarData().finalHeight,
                    builder: (context, finalHeight, child) {
                      return AnimatedContainer(
                        width: double.infinity,
                        duration: Duration(milliseconds: _animationDurationMs),
                        height: (initialLoadDone && welcomeTextDisplayed)
                            ? finalHeight + ds.Spacing.mediumPadding
                            : 0,
                        curve: Curves.linear,
                        child: Container(
                          decoration: BoxDecoration(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_5
                                  : ds.DesignColor.grey.grey_1),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: ds.Spacing.smallPadding),
                            child: SingleChildScrollView(
                              child: StatusBar(
                                onGetSize: (height) {
                                  if (initialLoadDone &&
                                      StatusBarData().finalHeight.value !=
                                          height) {
                                    // useful for debug
                                    StatusBarData().finalHeight.value = height;
                                  }
                                },
                                onTerminate: () {
                                  setState(() {
                                    StatusBarData().displayed.value = false;
                                  });
                                },
                                onTaskCardSelected: widget.onTaskCardSelected,
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}
