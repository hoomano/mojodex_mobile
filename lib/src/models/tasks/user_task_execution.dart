import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/serializable_data_item.dart';
import 'package:mojodex_mobile/src/models/session/messages/user_message.dart';
import 'package:mojodex_mobile/src/models/session/task_session.dart';
import 'package:mojodex_mobile/src/models/tasks/edit_text_actions.dart';
import 'package:mojodex_mobile/src/models/tasks/produced_text.dart';
import 'package:mojodex_mobile/src/models/todos/todos.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';

import '../actions/predefined_actions.dart';

class UserTaskExecution extends SerializableDataItem
    with HttpCaller, ChangeNotifier {
  // Logger
  final Logger logger = Logger('UserTaskExecution');

  /// User task of this execution
  late int userTaskPk;

  /// the title of the task execution
  String? title;

  /// the summary of the task execution
  String? summary;

  /// the date when the task execution as started
  DateTime? startDate;

  /// the date when the task execution as ended
  DateTime? endDate;

  /// The first question displayed
  late String placeholderHeader;
  late String placeholderBody;

  /// the
  late List<Map<String, dynamic>> jsonInputs;

  /// Number of processes in this task execution
  //int nProcesses = 0;

  /// Number of todos in this task execution
  int nTodos = 0;

  /// Whether Mojo is working on todos or not yet
  bool workingOnTodos = false;

  /// the produced text delivered by this task execution
  ProducedText? producedText;

  /// Session to which this task execution is associated
  late TaskSession session;

  List<PredefinedAction> predefinedActions = [];

  /// the text edit actions associated to the produced text
  List<TextEditAction> _textEditActions = [];
  List<TextEditAction> get textEditActions => _textEditActions;

  void correctProducedText(String initialText, String correctedText) {
    if (producedText == null || producedText!.production == null) return;
    producedText!.production = producedText!.production!
        .replaceAll(RegExp(initialText, caseSensitive: false), correctedText);
    producedText!.title = producedText!.title!
        .replaceAll(RegExp(initialText, caseSensitive: false), correctedText);
  }

  // used if userTaskExecution is created from the app
  UserTaskExecution(
      {required int userTaskExecutionPk,
      required this.userTaskPk,
      required this.jsonInputs,
      required String sessionId,
      required List<dynamic> actions,
      required List<dynamic> editActions,
      String? placeholderHeader,
      String? placeholderBody})
      : super(userTaskExecutionPk) {
    session = TaskSession(
        userTaskExecutionPk: userTaskExecutionPk,
        sessionId: sessionId,
        onReceivedNewDraft: (producedText) => this.producedText = producedText,
        onReceivedUserTaskExecutionTitle: (title) => this.title = title,
        correctProducedText: correctProducedText,
        onUserTaskExecutionStarted: (startDate) => start(startDate));
    this.placeholderHeader =
        placeholderHeader ?? jsonInputs[0]['description_for_user'];
    this.placeholderBody = placeholderBody ?? jsonInputs[0]['placeholder'];
    predefinedActions = List<PredefinedAction>.from(
        actions.map((x) => PredefinedAction.fromJson(x)));
    editActions.map((action) {
      _textEditActions.add(TextEditAction.fromJson(action));
    }).toList();
    workingOnTodos = true;
  }

  Future<void> updateFromJson(Map<String, dynamic> data) async {
    title = data['title'];
    summary = data['summary'];
    if (data['produced_text_pk'] != null) {
      producedText = ProducedText(
          producedTextPk: data['produced_text_pk'],
          producedTextVersionPk: data['produced_text_version_pk'],
          title: data['produced_text_title'],
          production: data['produced_text_production']);
    }
    nTodos = data['n_todos'] ?? 0;
    _nNotReadTodos = data['n_not_read_todos'] ?? 0;
    if (data['text_edit_actions'] != null) {
      _textEditActions = [];
      data['text_edit_actions'].map((action) {
        _textEditActions.add(TextEditAction.fromJson(action));
      }).toList();
    }
    workingOnTodos = data['working_on_todos'] ?? true;
    _deletedByUser = data['deleted_by_user'] ?? false;
    if (_deletedByUser) {
      User().userTaskExecutionsHistory.deleteItem(this);
    }
  }

  // used if the userTaskExecution is retrieved from backend
  @override
  UserTaskExecution.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    pk = data['user_task_execution_pk']!;
    userTaskPk = data['user_task_pk']!;

    // todo: remove once all backends deployed with this field
    startDate = data.containsKey("start_date")
        ? DateTime.tryParse(data['start_date'])
        : DateTime.now();
    endDate = DateTime.tryParse(data['end_date'].toString());
    session = TaskSession(
        userTaskExecutionPk: pk!,
        sessionId: data['session_id'],
        onReceivedNewDraft: (producedText) => this.producedText = producedText,
        onReceivedUserTaskExecutionTitle: (title) => this.title = title,
        correctProducedText: correctProducedText,
        onUserTaskExecutionStarted: (startDate) => start(startDate));

    predefinedActions = data['actions'] != null
        ? List<PredefinedAction>.from(
            data['actions'].map((x) => PredefinedAction.fromJson(x)))
        : [];

    updateFromJson(data);
  }

  // toJson function
  Map<String, dynamic> toJson() {
    return {
      'user_task_execution_pk': pk,
      'user_task_pk': userTaskPk,
      'session_id': session.sessionId,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'title': title,
      'summary': summary,
      'produced_text_pk': producedText?.producedTextPk,
      'produced_text_version_pk': producedText?.producedTextVersionPk,
      'produced_text_title': producedText?.title,
      'produced_text_production': producedText?.production,
      'n_todos': nTodos,
      'n_not_read_todos': _nNotReadTodos,
      'text_edit_actions': _textEditActions
          .map((textEditAction) => textEditAction.toJson())
          .toList(),
      'working_on_todos': workingOnTodos
    };
  }

  bool refreshing = false;

  /// Refresh the user task execution data that could have evolved while user was not on its view:
  /// - produced text (a new one can have been created)
  /// - todos (new ones can have been created)
  /// - working_on_todos (can have been changed)
  /// - title and summary (can have been changed)
  Future<void> refresh() async {
    if (refreshing) return;
    refreshing = true;
    notifyListeners();

    //resubmit old messages in error
    session.resubmitOldMessagesInError();
    List<Future> futures = [
      session.loadMoreMessages(nMessages: 10, loadOlder: false),
      _refreshData(),
      _refreshTodos(),
    ];
    await Future.wait(futures);
    refreshing = false;
    notifyListeners();
  }

  Future<void> _refreshData() async {
    Map<String, dynamic>? userTaskExecutionData = await get(
        service: "user_task_execution", params: "user_task_execution_pk=$pk");
    if (userTaskExecutionData != null) {
      updateFromJson(userTaskExecutionData);
    }
  }

  Future<void> _refreshTodos() async {
    List<Todo> newTodos = await _loadMoreTodos(nTodos: 10, offset: 0);
    _todos = newTodos;
  }

  /// List of todos of this user task execution
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  /// Number of todos not read in this user task execution
  int _nNotReadTodos = 0;
  int get nNotReadTodos => _nNotReadTodos;
  set nNotReadTodos(int n) {
    _nNotReadTodos = n;
  }

  // Boolean to know if the session is already loading todos
  bool loadingTodos = false;

  Future<void> reSubmit(UserMessage message) async {
    if (message.textEditActionPk != null) {
      await reSubmitTextEditActionMessage(message);
      return;
    }
    bool success = await session.reSubmit(message);
  }

  Future<void> start(DateTime startDate) async {
    if (this.startDate != null) return;
    this.startDate = startDate; // triggered by socketio message
    // add user task execution to the list of user task executions as first one
    User().userTaskExecutionsHistory.addItem(this);
  }

  Future<void> reSubmitTextEditActionMessage(UserMessage message) async {
    session.markMessageAsResubmitted(message);
    bool success = await runTextEditAction(
        message.textEditActionPk!, message.text,
        messagePk: message.messagePk);
    if (!success) {
      session.onSendMessageFailed(
          message, "Error while resubmitting textEditAction message");
    }
  }

  Future<bool> runTextEditAction(int textEditActionPk, String text,
      {int? messagePk}) async {
    // Send message to the chat with the text edit action's name
    UserMessage? message;
    if (messagePk == null) {
      message = UserMessage(text: text, textEditActionPk: textEditActionPk);
      session.addMessageToLocalList(message);
    }
    Map<String, dynamic> body = {
      'produced_text_version_pk': producedText!.producedTextVersionPk,
      'text_edit_action_pk': textEditActionPk
    };
    if (messagePk != null) {
      body['message_pk'] = messagePk;
    }
    Map<String, dynamic>? result =
        await post(service: 'text_edit_action', body: body);
    if (result == null) {
      return false;
    }
    if (messagePk == null) {
      message!.messagePk = result['message_pk'];
    }
    return true;
  }

  /// This method mark as read all the todos of the user
  Future<void> markTodosAsRead() async {
    Map<String, dynamic>? success = await post(
        service: 'todos',
        body: {'mark_as_read': true, 'user_task_execution_pk': pk});
    if (success != null) {
      for (Todo todo in todos) {
        if (!todo.readByUser) {
          await todo.markAsRead();
          User().todoList.nNotReadTodosNotifier.value -= 1;
        }
      }
    }
  }

  Future<List<Todo>> _loadMoreTodos({int? nTodos, required int offset}) async {
    if (loadingTodos) return todos;
    loadingTodos = true;
    Map? todosData;
    if (nTodos == null) {
      todosData = await _getUserTasksExecutionsTodos(offset: offset);
    } else {
      todosData = await _getUserTasksExecutionsTodos(
          offset: offset, maxTodosByCall: nTodos);
    }
    if (todosData != null) {
      bool addedToTodolist = false;
      List<Todo> loadedMessages = todosData['todos'].map<Todo>((todoData) {
        Todo? todo = User().todoList.getParticularItemSync(todoData['todo_pk']);

        if (todo != null) {
          return todo;
        } else {
          // if it is not in User().todos
          // add it to User().todos
          Todo newTodo = Todo.fromJson(todoData, displayedInUserList: false);
          User().todoList.addItem(newTodo);
          addedToTodolist = true;
          return newTodo;
        }
      }).toList();
      if (addedToTodolist) {
        User().todoList.refreshLocalList();
      }

      loadingTodos = false;
      return loadedMessages;
    }
    return [];
  }

  Future<void> loadMoreTodos({int? nTodos}) async {
    List<Todo> newTodos =
        await _loadMoreTodos(nTodos: nTodos, offset: todos.length);

    if (newTodos.isNotEmpty) {
      todos.addAll(newTodos);
      notifyListeners();
    }
  }

  /// get the list of the user tasks execution Todo from the backend
  Future<Map<String, dynamic>?> _getUserTasksExecutionsTodos(
      {offset = 0, maxTodosByCall = 20}) async {
    String params =
        "datetime=${DateTime.now().toIso8601String()}&user_task_execution_fk=$pk&n_todos=$maxTodosByCall&offset=$offset";
    return await get(service: 'todos', params: params);
  }

  /// Whether the user task execution has been deleted by the user
  bool _deletedByUser = false;
  bool get deletedByUser => _deletedByUser;

  Future<void> deleteUserTaskExecution() async {
    _deletedByUser = true;
    notifyListeners();
  }

  Future<void> deleteUserTaskExecutionBackend() async {
    if (!_deletedByUser) return;
    Map<String, dynamic>? success = await delete(
        service: "user_task_execution", params: "user_task_execution_pk=$pk");
    if (success == null) {
      _deletedByUser = false;
      notifyListeners();
    }
    User().userTaskExecutionsHistory.deleteItem(this);
  }

  Future<void> undoDeleteUserTaskExecution() async {
    _deletedByUser = false;
    notifyListeners();
  }
}
