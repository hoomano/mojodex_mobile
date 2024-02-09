import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task.dart';

import '../cached_list.dart';

class UserTasksList extends CachedList<UserTask> {
  final Logger logger = Logger('UserTasksList');

  UserTasksList()
      : super(
            localFileName: 'user_tasks.json',
            key: 'user_tasks',
            itemFromJson: UserTask.fromJson,
            service: 'user_task',
            pkKey: 'user_task_pk',
            nItemsKey: 'n_user_tasks',
            maxItemsInLocalFile: 50);

  /// get userTask from taskPk
  UserTask? getUserTaskFromTaskPk(int taskPk) {
    return items.firstWhereOrNull((userTask) => userTask.task.pk == taskPk);
  }
}
