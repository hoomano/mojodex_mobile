import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:mojodex_mobile/src/views/workflows_view/user_workflow_execution_view.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/workflows/user_worklow_execution.dart';
import '../../models/workflows/workflow.dart';
import '../drawer/app_drawer.dart';

class NewUserWorkflowExecution extends StatefulWidget {
  static const String routeName = "new_user_workflow_execution";
  late Workflow workflow;
  late UserWorkflow userWorkflow;
  NewUserWorkflowExecution({Key? key}) : super(key: key) {
    workflow = Workflow(pk: 1, name: "Translation workflow");
    userWorkflow = UserWorkflow(userWorkflowPk: 1, workflow: workflow);
  }

  @override
  State<NewUserWorkflowExecution> createState() =>
      _NewUserWorkflowExecutionState();
}

class _NewUserWorkflowExecutionState extends State<NewUserWorkflowExecution> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return MojodexScaffold(
        drawer: AppDrawer(),
        appBarTitle: "New workflow",
        // a centered button that says "Start new workflow",
        body: Center(
          child: loading
              ? CircularProgressIndicator()
              : ds.Button.fill(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    UserWorkflowExecution? userWorkflowExecution =
                        await widget.userWorkflow.newExecution();
                    if (userWorkflowExecution == null) {
                      setState(() {
                        loading = false;
                      });
                      return;
                    }
                    UserWorkflowExecutionView userWorkflowExecutionView =
                        UserWorkflowExecutionView(
                            userWorkflowExecution: userWorkflowExecution);
                    context.pushNamed(UserWorkflowExecutionView.routeName,
                        extra: userWorkflowExecutionView);
                  },
                  text: "Translation workflow",
                ),
        ),
        safeAreaOverflow: false);
  }
}
