import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/models/todos/todos.dart';

import '../cached_list.dart';
import '../user/user.dart';

class TodoList extends CachedList<Todo> {
  // Logger
  final Logger logger = Logger('TodoList');

  TodoList()
      : super(
          localFileName: 'todos.json',
          key: 'todos',
          itemFromJson: Todo.fromJson,
          service: 'todos',
          pkKey: 'todo_pk',
          nItemsKey: 'n_todos',
        );

  bool neverDoneTodos = true;

  /// Notifier for the number of not read todos
  /// Produce that the todos tab rebuild when the number of not read todos change
  ValueNotifier<int> nNotReadTodosNotifier = ValueNotifier<int>(0);
  int get nNotReadTodos => nNotReadTodosNotifier.value;

  /// This method mark as read all the todos of the user
  Future<void> markAllTodosAsRead() async {
    Map<String, dynamic>? success = await post(service: service, body: {
      'mark_as_read': true,
    });
    if (success != null) {
      for (Todo todo in items) {
        if (!todo.readByUser) {
          await todo.markAsRead();
          nNotReadTodosNotifier.value -= 1;
        }
      }
    }
  }

  @override
  List<Todo> dataToItems(Map<String, dynamic> itemsData) {
    nNotReadTodosNotifier.value = itemsData['n_todos_not_read'];
    neverDoneTodos = itemsData['user_has_never_done_todo'];
    List<Todo> todos = [];
    for (Map<String, dynamic> todoData in itemsData[key]) {
      int todoPk = todoData[pkKey];
      // is todoPk already in _todos ?
      Todo? todo = items.firstWhereOrNull((todo) => todo.pk == todoPk);
      if (todo != null) {
        todo.displayedInUserList = true;
        todos.add(todo);
      } else {
        Todo todo = Todo.fromJson(todoData);
        // Add todo to the respective user_task_execution todo list
        UserTaskExecution? userTaskExecution = User()
            .userTaskExecutionsHistory
            .getParticularItemSync(todoData['user_task_execution_fk']);
        if (userTaskExecution != null) {
          // Add todo if it wasn't already added
          int todoIndex =
              userTaskExecution.todos.indexWhere((todo) => todo.pk == todoPk);
          if (todoIndex == -1) {
            userTaskExecution.todos.add(todo);
          }
        }
        todos.add(todo);
      }
    }
    return todos;
  }

  int get currentDisplayedListOffset =>
      items.where((todo) => todo.displayedInUserList).length;

  List<Todo> get displayedTodos => items
      .where((todo) => (todo.displayedInUserList && todo.visible))
      .toList();

  @override
  Future<void> writeFile(Map<String, dynamic> data) async {
    // add to data user_has_never_done_todo and n_todos_not_read
    data['user_has_never_done_todo'] = neverDoneTodos;
    data['n_todos_not_read'] = nNotReadTodos;
    await super.writeFile(data);
  }
}
