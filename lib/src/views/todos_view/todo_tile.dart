import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/skeletons/skeleton_list.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/user_task_execution_view.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../app_router.dart';
import '../../models/tasks/user_task_execution.dart';
import '../../models/todos/todos.dart';
import '../../models/user/user.dart';

typedef UndoAction = Future<void> Function();

class TodoTile extends StatefulWidget {
  final Function? onLoading;
  final Function? onLoadingOver;
  final bool navigateToUserTaskExecutionViewOnTap;
  final bool showCompleted;
  final Function onVisibilityChanged;
  const TodoTile(
      {this.navigateToUserTaskExecutionViewOnTap = false,
      this.onLoading,
      this.onLoadingOver,
      this.showCompleted = false,
      required this.onVisibilityChanged,
      Key? key})
      : super(key: key);

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Color getDescriptionColor(Todo todo) {
      if (themeProvider.themeMode == ThemeMode.dark) {
        return todo.isOutDated && !todo.completed
            ? ds.DesignColor.grey.grey_3
            : ds.DesignColor.grey.grey_1;
      } else {
        return todo.isOutDated && !todo.completed
            ? ds.DesignColor.grey.grey_3
            : ds.DesignColor.grey.grey_9;
      }
    }

    return Consumer<Todo>(
        builder: ((BuildContext context, Todo todo, Widget? child) {
      SnackBar _buildSnackBar(
          {required String initialText,
          required UndoAction undoAction,
          required String actionText}) {
        // hide current snackbar if any
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(initialText),
              GestureDetector(
                  onTap: () {
                    undoAction();
                    // hide current snackbar
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(actionText)));
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

      bool isTodoVisible = true;
      if (todo.completed) {
        if (widget.showCompleted) {
          isTodoVisible = true;
        } else {
          isTodoVisible = todo.visible;
        }
      } else {
        isTodoVisible = todo.visible;
      }

      return Visibility(
        visible: isTodoVisible,
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: SkeletonList(
                      itemCount: 1,
                    )),
              )
            : GestureDetector(
                onTap: () async {
                  if (!widget.navigateToUserTaskExecutionViewOnTap) return;
                  widget.onLoading!();
                  setState(() {
                    loading = true;
                  });
                  UserTaskExecution? userTaskExecution = await User()
                      .userTaskExecutionsHistory
                      .getParticularItem(todo.userTaskExecutionFk);
                  if (userTaskExecution != null) {
                    await AppRouter().goRouter.push(
                        '/${UserTaskExecutionsListView.routeName}/${todo.userTaskExecutionFk}',
                        extra: UserTaskExecutionView(
                          userTaskExecution: userTaskExecution,
                          initialTab: UserTaskExecutionView.todosTabName,
                        ));
                  }
                  setState(() {
                    loading = false;
                  });
                  widget.onLoadingOver!();
                },
                child: Dismissible(
                  key: Key(todo.pk.toString()),
                  onDismissed: (direction) {
                    todo.deleteTodo();
                    // Show a snackbar to indicate the item is dismissed
                    SnackBar snackbar = _buildSnackBar(
                        initialText: "Todo dismissed",
                        undoAction: () async {
                          todo.undoDeleteTodo();
                        },
                        actionText: "Todo restored");
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackbar)
                        .closed
                        .then((value) {
                      todo.deleteTodoBackend();
                      widget.onVisibilityChanged();
                    });
                  },
                  background: Row(
                    children: [
                      Container(
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: ds.Spacing.largePadding),
                      ),
                      Expanded(
                          child: Container(
                        color: Colors.red,
                      )),
                      Container(
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerRight,
                        padding:
                            EdgeInsets.only(right: ds.Spacing.largePadding),
                      ),
                    ],
                  ),
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: ds.Spacing.largePadding),
                    child: ds.Pills.primary(
                      type: ds.PillsType.fill,
                      alignment: AlignmentDirectional.centerStart,
                      visibility: !todo.readByUser,
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          top: ds.Spacing.mediumPadding,
                          bottom: ds.Spacing.mediumPadding,
                          left: ds.Spacing.largePadding,
                          right: ds.Spacing.mediumPadding,
                        ),
                        title: Text(
                          todo.description,
                          style: TextStyle(
                            color: getDescriptionColor(todo),
                            fontSize: ds.TextFontSize.body2,
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : null,
                            fontStyle: todo.completed || todo.isOutDated
                                ? FontStyle.italic
                                : FontStyle.normal,
                            decorationThickness: 2.0,
                          ),
                        ),
                        leading: todo.isOutDated && !todo.completed
                            ? ds.DesignIcon.stopSign(
                                color: ds.DesignColor.grey.grey_3,
                                size: ds.TextFontSize.h2)
                            : ds.Checkbox(
                                size: ds.TextFontSize.h2,
                                value: todo.completed,
                                color: ds.DesignColor.grey.grey_3,
                                onChanged: (value) {
                                  if (todo.completed) return;
                                  todo.complete();

                                  // Show a snackbar to indicate the item is dismissed
                                  SnackBar snackbar = _buildSnackBar(
                                      initialText: "Todo completed",
                                      undoAction: todo.undoComplete,
                                      actionText: "Todo uncompleted");
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackbar)
                                      .closed
                                      .then((value) {
                                    todo.completeBackend();
                                    widget.onVisibilityChanged();
                                  });
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
      );
    }));
  }
}
