import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/workflows_view/process_view/step_widget.dart';
import 'package:mojodex_mobile/src/views/workflows_view/process_view/user_worflow_execution_form.dart';

import '../../../models/workflows/user_worklow_execution.dart';

class ProcessView extends StatelessWidget {
  final UserWorkflowExecution userWorkflowExecution;
  final Function() onReject;
  const ProcessView(
      {required this.userWorkflowExecution, required this.onReject, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Visibility(
          visible: userWorkflowExecution.startDate == null,
          child: UserWorkflowExecutionForm(
              userWorkflowExecution: userWorkflowExecution),
        )
      ]..addAll(userWorkflowExecution.stepExecutions
          .map((stepExecution) => StepExecutionWidget(
              stepExecution: stepExecution, onReject: onReject))
          .cast()),
    ));
  }
}
