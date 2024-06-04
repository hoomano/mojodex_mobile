import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/session/home_chat_session.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';

class WelcomeMessage extends StatelessWidget {
  final HomeChatSession session;
  const WelcomeMessage({required this.session, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return StreamBuilder<String?>(
        stream: session.welcomeMessageTokenStream,
        builder: (context, snapshot) {
          //print("===> ${session.onGoingMojoMessageHeader}");
          return Padding(
              padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    session.onGoingMojoMessageHeader ?? "",
                    style: TextStyle(
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.white
                            : ds.DesignColor.grey.grey_5,
                        fontWeight: FontWeight.bold,
                        fontSize: ds.TextFontSize.h4),
                    textAlign: TextAlign.center,
                  ),
                  ds.Space.verticalLarge,
                  Text(session.onGoingMojoMessageBody ?? "",
                      style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.white
                              : ds.DesignColor.grey.grey_7,
                          fontSize: ds.TextFontSize.body1),
                      textAlign: TextAlign.center),
                  ds.Space.verticalLarge,
                ],
              ));
        });
  }
}
