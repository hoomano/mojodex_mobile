import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/session/messages/user_message.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/chat_bottom_bar.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/messages_list.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/session/session.dart';

class ChatView extends StatelessWidget {
  final UserTaskExecution userTaskExecution;
  final UserMessage? firstMessageToSend;
  ChatView({required this.userTaskExecution, this.firstMessageToSend});

  void onResubmit(UserMessage message) {
    userTaskExecution.reSubmit(message);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(child: Consumer<Session>(
        builder: (BuildContext context, Session session, Widget? child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (firstMessageToSend != null && session.messages.isEmpty) {
          session.addMessage(firstMessageToSend!);
        }
      });
      return Column(
        children: [
          Expanded(
            child: userTaskExecution.startDate == null &&
                    session.messages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          userTaskExecution.placeholderHeader,
                          style: TextStyle(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.white
                                  : ds.DesignColor.grey.grey_5,
                              fontWeight: FontWeight.bold,
                              fontSize: ds.TextFontSize.h4),
                          textAlign: TextAlign.center,
                        ),
                        ds.Space.verticalLarge,
                        Text(userTaskExecution.placeholderBody,
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.white
                                    : ds.DesignColor.grey.grey_7,
                                fontSize: ds.TextFontSize.body1),
                            textAlign: TextAlign.center),
                        ds.Space.verticalLarge,
                      ],
                    ))
                : MessagesList(session: session, onResubmit: onResubmit),
          ),
          ChatBottomBar(session: session)
        ],
      );
    }));
  }
}
