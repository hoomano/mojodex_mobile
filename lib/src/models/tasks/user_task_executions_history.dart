import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';

import '../cached_list.dart';

class UserTaskExecutionsHistory extends CachedList<UserTaskExecution> {
  // Logger
  final Logger logger = Logger('UserTaskExecutionsHistory');

  UserTaskExecutionsHistory()
      : super(
            localFileName: 'user_task_executions_history.json',
            key: 'user_task_executions',
            itemFromJson: UserTaskExecution.fromJson,
            service: 'user_task_execution',
            pkKey: 'user_task_execution_pk',
            nItemsKey: 'n_user_task_executions');

  final ValueNotifier<bool> _initialLoadDone = ValueNotifier<bool>(false);
  ValueNotifier<bool> get initialLoadDone => _initialLoadDone;

  String? userTaskExecutionsAreFilteredBy;
  List<int> userTaskExecutionsAreFilteredByUserTaskPks = [];

  bool get userTaskExecutionsAreFiltered =>
      userTaskExecutionsAreFilteredBy != null ||
      userTaskExecutionsAreFilteredByUserTaskPks.isNotEmpty;

  /// load the more user_task_executions
  @override
  Future<bool> loadMoreItems(
      {int maxItemsByCall = 50, required int offset}) async {
    if (loading) return false;
    loading = true;
    notifyListeners();

    Map<String, dynamic>? userTaskExecutionsData;
    bool loadFromBackend = true;
    // if there is no filter and offset is 0, load from local file if it exists
    if (offset == 0 && !userTaskExecutionsAreFiltered) {
      bool fileExists = await (await localFile).exists();
      if (fileExists) {
        userTaskExecutionsData = await loadListFromLocalFile();
        loadFromBackend = false;
      }
    }

    if (loadFromBackend) {
      userTaskExecutionsData =
          await getItems(offset: offset, maxItemsByCall: maxItemsByCall);
    }

    if (userTaskExecutionsData != null) {
      List<UserTaskExecution> userTaskExecutions =
          userTaskExecutionsData['user_task_executions']
              .map<UserTaskExecution>((userTaskExecutionData) =>
                  UserTaskExecution.fromJson(userTaskExecutionData))
              .toList();
      items.addAll(userTaskExecutions);
      if (items.isNotEmpty && !User().hasAlreadyDoneTask) {
        User().hasAlreadyDoneTask = true;
      }
    }
    if (offset == 0 && !userTaskExecutionsAreFiltered) {
      if (loadFromBackend) {
        await (await localFile)
            .writeAsString(jsonEncode(userTaskExecutionsData));
        logger.info("user_task_executions_history saved to local file");
      } else {
        refreshLocalList();
      }
    }

    loading = false;
    notifyListeners();
    if (!initialLoadDone.value) {
      initialLoadDone.value = true;
      initialLoadDone.notifyListeners();
    }
    return true;
  }

  /// get the list of the user_task_executions history
  /// returns a map with a single field user_task_executions which contains the list of the user_task_executions data as json
  /// or null if an error occurred
  @override
  Future<Map<String, dynamic>?> getItems(
      {int offset = 0, int maxItemsByCall = 20, int retry = 3}) async {
    try {
      String params = "$nItemsKey=$maxItemsByCall&offset=$offset";
      if (userTaskExecutionsAreFilteredBy != null) {
        params = "$params&search_filter=$userTaskExecutionsAreFilteredBy";
      }
      if (userTaskExecutionsAreFilteredByUserTaskPks.isNotEmpty) {
        params =
            "$params&user_task_pks=${userTaskExecutionsAreFilteredByUserTaskPks.join(";")}";
      }
      return await get(service: service, params: params);
    } catch (e) {
      if (e is TimeoutException && retry > 0) {
        logger.warning("getItems timeout, retrying $retry");
        return await getItems(
            offset: offset, maxItemsByCall: maxItemsByCall, retry: retry - 1);
      }
      logger.shout("Error getting items: $e");
      return null;
    }
  }

  @override
  void addItem(UserTaskExecution userTaskExecution) {
    items.insert(0, userTaskExecution);
    if (!User().hasAlreadyDoneTask) {
      User().hasAlreadyDoneTask = true;
    }
    notifyListeners();
    saveItemsToFile();
  }

  @override
  void empty() {
    super.empty();
    initialLoadDone.value = false;
  }
}
