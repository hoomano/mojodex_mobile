import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/deleted_user_task_execution.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/user_task_execution_view.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/theme/themes.dart';
import '../../models/session/messages/user_message.dart';

class LoadUserTaskExecutionView extends StatelessWidget {
  final int userTaskExecutionPk;
  final String initialTab;
  final UserMessage? firstMessageToSend;

  const LoadUserTaskExecutionView(
      {super.key,
      required this.userTaskExecutionPk,
      required this.initialTab,
      this.firstMessageToSend});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder<UserTaskExecution?>(
        future: User()
            .userTaskExecutionsHistory
            .getParticularItemAsync(userTaskExecutionPk),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MojodexScaffold(
              appBarTitle: "Loading",
              safeAreaOverflow: false,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const DeletedUserTaskExecution();
          }

          assert(snapshot.hasData);
          final userTaskExecution = snapshot.data!;
          return UserTaskExecutionView(
            userTaskExecution: userTaskExecution,
            initialTab: initialTab,
            firstMessageToSend: firstMessageToSend,
          );
        });
  }
}
