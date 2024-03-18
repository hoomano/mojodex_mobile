import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/workflows_view/run_widget.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/workflows/user_workflow_step_execution.dart';

class StepExecutionWidget extends StatelessWidget {
  final UserWorkflowStepExecution stepExecution;
  const StepExecutionWidget({super.key, required this.stepExecution});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: stepExecution.initialized ? 1 : 0.5,
      child: Container(
        padding: EdgeInsets.all(ds.Spacing.base),
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: Column(
              children: [
                Text(
                  stepExecution.step.name,
                  style: TextStyle(
                      fontSize: ds.TextFontSize.h5,
                      fontWeight: FontWeight.bold),
                ),
              ]..addAll(stepExecution.runs.map((run) => RunWidget(run: run))),
            )),
      ),
    );
  }
}