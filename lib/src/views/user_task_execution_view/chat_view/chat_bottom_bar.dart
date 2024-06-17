import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/views/widgets/spelling_corrector.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/language/system_language.dart';
import '../../../models/session/messages/user_message.dart';
import '../../../models/session/session.dart';
import '../../../models/user/user.dart';
import '../../../notifications_manager.dart';
import '../../widgets/text_area_mic.dart';

class ChatBottomBar extends StatelessWidget {
  final Session session;

  ChatBottomBar({required this.session});

  void onValidate(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    ds.Modal(
      icon: labelsProvider.getText(
          key: "userTaskExecution.chatTab.notificationValidation.emoji"),
      title: labelsProvider.getText(
          key: "userTaskExecution.chatTab.notificationValidation.title"),
      textContent: (User().notifAllowed == null || !User().notifAllowed!)
          ? labelsProvider.getText(
              key:
                  "userTaskExecution.chatTab.notificationValidation.textContent.notifAllowed")
          : labelsProvider.getText(
              key:
                  "userTaskExecution.chatTab.notificationValidation.textContent.notNotifAllowed"),
      acceptButtonText: (User().notifAllowed == null || !User().notifAllowed!)
          ? labelsProvider.getText(
              key:
                  "userTaskExecution.chatTab.notificationValidation.acceptButtonText.notifAllowed")
          : labelsProvider.getText(
              key:
                  "userTaskExecution.chatTab.notificationValidation.acceptButtonText.notNotifAllowed"),
      onAccept: () async {
        context.pop();
        if (User().notifAllowed == null || !User().notifAllowed!) {
          await NotificationsManager().askPermission();
        }
        context.pop();
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (session.loadingNewerMessages) {
      return Padding(
        padding: const EdgeInsets.all(ds.Spacing.smallPadding),
        child: LinearProgressIndicator(
          color: ds.DesignColor.primary.main,
          backgroundColor: themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_7
              : ds.DesignColor.grey.grey_3,
        ),
      );
    }
    if (session.textPortionInCorrection != null) {
      return SpellingCorrector(
          text: session.textPortionInCorrection!,
          onFinishSpellingCorrection: session.onFinishSpellingCorrection,
          onDismissed: session.abandonSpellingCorrection);
    } else {
      return TextAreaMic(
        onSubmit: ({String? userText, String? audioFilePath}) {
          // create a message
          UserMessage message = UserMessage(hasAudio: true);
          session.addMessage(message);
          // update thanks to session provider
        },
        filename: 'user_message',
        enableText: false,
        microAvailable: session.waitingForMojo,
      );
    }
    // });
  }
}
