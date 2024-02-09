import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_card.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/tasks/user_task_execution.dart';
import '../user_task_execution_view/user_task_execution_view.dart';

class UserTaskExecutionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserTaskExecution>(builder: ((BuildContext context,
        UserTaskExecution userTaskExecution, Widget? child) {
      void onTap() async {
        // reload userTaskExecution todos to check if there are new todos
        userTaskExecution.refresh();

        // await to execute the code below just after have returned
        // from the user_task _execution_view
        await context.push(
            '/${UserTaskExecutionsListView.routeName}/${userTaskExecution.pk}',
            extra: UserTaskExecutionView(
              userTaskExecution: userTaskExecution,
              initialTab: userTaskExecution.producedText != null
                  ? UserTaskExecutionView.resultTabName
                  : UserTaskExecutionView.chatTabName,
            ));
      }

      SnackBar _buildDeletionSnackBar() {
        // hide current snackbar if any
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Task deleted"),
              GestureDetector(
                  onTap: () {
                    userTaskExecution.undoDeleteUserTaskExecution();
                    // hide current snackbar
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Task restored")));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                    child: Text(
                      'Undo',
                      style: TextStyle(
                        color: ds.DesignColor.primary.main,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ],
          ),
        );
      }

      return Visibility(
        visible: !userTaskExecution.deletedByUser,
        child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.base),
            child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(),
                onLongPress: () => onTap(),
                child: UserTaskExecutionCard(
                  userTaskExecution: userTaskExecution,
                  onDismissed: (direction) {
                    userTaskExecution.deleteUserTaskExecution();
                    // Show a snackbar to indicate the item is dismissed
                    SnackBar snackbar = _buildDeletionSnackBar();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackbar)
                        .closed
                        .then((value) {
                      userTaskExecution.deleteUserTaskExecutionBackend();
                    });
                  },
                ))),
      );
    }));
  }
}
