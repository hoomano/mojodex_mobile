import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow.dart';

import '../cached_list.dart';

class UserWorkflowsList extends CachedList<UserWorkflow> {
  final Logger logger = Logger('UserWorkflowsList');

  UserWorkflowsList()
      : super(
            localFileName: 'user_workflows.json',
            key: 'user_workflows',
            itemFromJson: UserWorkflow.fromJson,
            service: 'user_workflow',
            pkKey: 'user_workflow_pk',
            nItemsKey: 'n_user_workflows',
            maxItemsInLocalFile: 50);

  /// get userWorkflow from workflowPk
  UserWorkflow? getUserWorkflowFromWorkflowPk(int workflowPk) {
    return items.firstWhereOrNull(
        (userWorkflow) => userWorkflow.workflow.pk == workflowPk);
  }
}
