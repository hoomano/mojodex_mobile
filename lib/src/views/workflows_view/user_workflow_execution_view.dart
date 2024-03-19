import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:mojodex_mobile/src/views/workflows_view/step_widget.dart';
import 'package:mojodex_mobile/src/views/workflows_view/user_worflow_execution_form.dart';
import 'package:provider/provider.dart';

import '../../models/workflows/user_worklow_execution.dart';

class UserWorkflowExecutionView extends StatefulWidget {
  static const String routeName = "user_workflow_execution";

  final UserWorkflowExecution userWorkflowExecution;

  const UserWorkflowExecutionView(
      {Key? key, required this.userWorkflowExecution})
      : super(key: key);

  @override
  State<UserWorkflowExecutionView> createState() =>
      _UserWorkflowExecutionViewState();
}

class _UserWorkflowExecutionViewState extends State<UserWorkflowExecutionView> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // if session is not already connected, connect to it
    widget.userWorkflowExecution.session.connectToSession();
  }

  @override
  Widget build(BuildContext context) {
    return MojodexScaffold(
        appBarTitle: "Workflow",
        body: ChangeNotifierProvider<UserWorkflowExecution>.value(
            value: widget.userWorkflowExecution,
            child: Consumer<UserWorkflowExecution>(
                builder: (context, userWorkflowExecution, child) {
              return Center(
                  child: Column(
                children: [
                  Text("Workflow ${userWorkflowExecution.pk}"),
                  Visibility(
                    visible: userWorkflowExecution.startDate == null,
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : UserWorkflowExecutionForm(
                            userWorkflowExecution: userWorkflowExecution),
                  )
                ]..addAll(userWorkflowExecution.stepExecutions
                    .map((stepExecution) =>
                        StepExecutionWidget(stepExecution: stepExecution))
                    .cast()),
              ));
            })),
        safeAreaOverflow: false);
  }
}
