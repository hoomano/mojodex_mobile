import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mojodex_mobile/src/views/todos_view/todos_list.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/todos_view/empty_todo_view.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/tasks/user_task_execution.dart';
import '../../../models/todos/todos.dart';
import '../../skeletons/skeleton_list.dart';

class UserTaskExecutionTodosList extends StatefulWidget {
  final UserTaskExecution userTaskExecution;

  UserTaskExecutionTodosList({super.key, required this.userTaskExecution});

  @override
  State<UserTaskExecutionTodosList> createState() =>
      _UserTaskExecutionTodosListState();
}

class _UserTaskExecutionTodosListState
    extends State<UserTaskExecutionTodosList> {
  int nTodosLoadingBatchSize = 10;
  double lastScrollOffset = 0;

  bool _processingRequest = false;

  final ScrollController _scrollController = ScrollController();

  Future<void> _loadMoreTodos() async {
    if (_processingRequest) return;
    _processingRequest = true;
    await widget.userTaskExecution
        .loadMoreTodos(nTodos: nTodosLoadingBatchSize);
    _processingRequest = false;
    if (mounted)
      setState(
          () {}); // TODO: ON setstate, only new todos should be built, not all rebuilt.
  }

  void setStateIfMounted() {
    if (!mounted) return;
    setState(() {});
  }

  void onScrollChange() {
    lastScrollOffset = _scrollController.offset;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScrollChange);

    // Delete the not read todos badge when switch to todos tab
    // but do not mark todos as read yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.userTaskExecution.markTodosAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScrollChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(lastScrollOffset);
      }
    });
    List<Todo> todos = widget.userTaskExecution.todos.toList();
    if (todos.isEmpty && widget.userTaskExecution.refreshing) {
      return SkeletonList();
    }
    return AbsorbPointer(
      absorbing: widget.userTaskExecution.refreshing,
      child: Column(
        children: [
          Expanded(
              child: widget.userTaskExecution.nTodos == 0
                  ? EmptyTodoForUserTaskExecution(
                      userTaskExecution: widget.userTaskExecution)
                  : LazyLoadScrollView(
                      onEndOfPage: () {
                        _loadMoreTodos();
                      },
                      child: SingleChildScrollView(
                        child: TodosList(todos: todos, showCompleted: true),
                      ),
                    )),
          if (widget.userTaskExecution.refreshing)
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.smallPadding),
              child: LinearProgressIndicator(
                color: ds.DesignColor.primary.main,
                backgroundColor: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_7
                    : ds.DesignColor.grey.grey_3,
              ),
            )
        ],
      ),
    );
  }
}
