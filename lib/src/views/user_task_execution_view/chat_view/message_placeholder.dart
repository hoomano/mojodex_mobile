import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/message_container.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';

class MessagePlaceholder extends StatelessWidget {
  final bool rounded;
  final Stream<String?>? stream;
  final String? onGoingMojoMessage;

  const MessagePlaceholder(
      {super.key,
      required this.stream,
      this.onGoingMojoMessage,
      this.rounded = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MessageContainer(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
              color: themeProvider.themeMode == ThemeMode.dark
                  ? ds.DesignColor.grey.grey_7
                  : ds.DesignColor.grey.grey_1,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: ds.Spacing.smallPadding,
                horizontal: ds.Spacing.mediumPadding),
            child: stream == null
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: LoadingAnimationWidget.waveDots(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9,
                      size: 30,
                    ))
                : StreamBuilder<String?>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.data != null) {
                        return Text(snapshot.data ?? '',
                            style: TextStyle(
                                fontSize: ds.TextFontSize.body2,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9),
                            textScaleFactor: 1.05);
                      } else if (onGoingMojoMessage != null) {
                        return Text(onGoingMojoMessage!,
                            style: TextStyle(
                                fontSize: ds.TextFontSize.body2,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9),
                            textScaleFactor: 1.05);
                      }
                      return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: LoadingAnimationWidget.waveDots(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_1
                                : ds.DesignColor.grey.grey_9,
                            size: 30,
                          ));
                    }),
          ),
        ),
      ),
    );
  }
}
