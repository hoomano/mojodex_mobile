import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';

import '../http_caller.dart';
import '../serializable_data_item.dart';

class Todo extends SerializableDataItem with HttpCaller, ChangeNotifier {
  // Logger
  final Logger logger = Logger('Todo');

  /// Has the todo been loaded by User().todos yet?
  late bool displayedInUserList;

  /// Associated user_task_execution
  late int userTaskExecutionFk;

  /// the description of the todo
  late String description;

  /// the scheduled date of the todo
  late DateTime scheduledDate;

  bool get isOutDated {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day, 0, 0, 0);
    return scheduledDate.isBefore(midnight);
  }

  /// archived is true if the todo has been done by the user
  bool _completed = false;
  bool get completed => _completed;

  /// deleted by user
  bool _deletedByUser = false;
  bool get deletedByUser => _deletedByUser;

  /// read by user
  bool _readByUser = false;
  bool get readByUser => _readByUser;

  Todo.fromJson(Map<String, dynamic> data, {this.displayedInUserList = true})
      : super.fromJson(data) {
    pk = data['todo_pk'] ?? pk;
    userTaskExecutionFk = data['user_task_execution_fk'] ?? userTaskExecutionFk;
    description = data['description'];
    scheduledDate = DateTime.parse(data['scheduled_date']);
    _completed = data['completed'] != null;
    _readByUser = data['read_by_user'] != null;
    displayedInUserList = data.containsKey('displayed_in_user_list')
        ? data['displayed_in_user_list']
        : true;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['todo_pk'] = pk;
    data['user_task_execution_fk'] = userTaskExecutionFk;
    data['description'] = description;
    data['scheduled_date'] = scheduledDate.toString();
    data['completed'] = completed ? completed : null;
    data['read_by_user'] = _readByUser ? _readByUser : null;
    data['displayed_in_user_list'] = displayedInUserList;
    return data;
  }

  /// This boolean is used to determine if the todo is visible or not
  /// because when a user deletes a todo, they can see it for a a second then it disappears
  bool _visible = true;
  bool get visible => _visible;

  Timer? _setTodoUnvisibleTimer;

  Future<void> complete() async {
    if (_completed) return;
    _completed = true;
    _visible = true;
    notifyListeners();

    _setTodoUnvisibleTimer = Timer(Duration(seconds: 1), () {
      _visible = false;
      notifyListeners();
    });
  }

  Future<void> completeBackend() async {
    if (!_completed) return;
    Map<String, dynamic>? success = await post(
        service: 'todos', body: {'mark_as_done': true, 'todo_pk': pk});
    if (success == null) {
      _completed = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead() async {
    _readByUser = true;
    UserTaskExecution? userTaskExecution = await User()
        .userTaskExecutionsHistory
        .getParticularItem(userTaskExecutionFk);
    if (userTaskExecution != null) {
      userTaskExecution.nNotReadTodos--;
    }
  }

  Future<void> undoComplete() async {
    _completed = false;
    _visible = true;
    if (_setTodoUnvisibleTimer != null) _setTodoUnvisibleTimer!.cancel();
    notifyListeners();
  }

  Future<void> deleteTodo() async {
    _deletedByUser = true;
    _visible = false;
    notifyListeners();
  }

  Future<void> deleteTodoBackend() async {
    if (!_deletedByUser) return;
    Map<String, dynamic>? success =
        await delete(service: 'todos', params: "todo_pk=$pk");
    if (success == null) {
      _deletedByUser = false;
      _visible = true;
      notifyListeners();
    }
  }

  Future<void> undoDeleteTodo() async {
    _deletedByUser = false;
    _visible = true;
    notifyListeners();
  }
}
