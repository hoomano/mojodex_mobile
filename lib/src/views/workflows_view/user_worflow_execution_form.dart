import 'package:flutter/material.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/workflows/user_worklow_execution.dart';

class UserWorkflowExecutionForm extends StatelessWidget {
  final UserWorkflowExecution userWorkflowExecution;
  late Map<String, dynamic> fieldValues;

  UserWorkflowExecutionForm({required this.userWorkflowExecution, Key? key})
      : super(key: key) {
    fieldValues = {
      for (var input in userWorkflowExecution.inputs)
        input['input_name']: input['default_value'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Build text fields for each input
          for (var input in userWorkflowExecution.inputs)
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.smallPadding),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: input['input_name'] ?? 'Input',
                  border: OutlineInputBorder(),
                ),
                initialValue: input['default_value']?.toString(),
                onChanged: (value) {
                  fieldValues[input['input_name']] = value;
                },
              ),
            ),
          SizedBox(height: 20), // Add some space between fields and button
          // Start button
          ds.Button.fill(
              onPressed: () async {
                /* setState(() {
                    loading = true;
                  });*/
                Map<String, dynamic>? response =
                    await userWorkflowExecution.start(fieldValues);
                if (response == null) {
                  /*setState(() {
                      loading = false;
                    });*/
                  return;
                }
              },
              text: "Start")
        ],
      ),
    );
  }
}
