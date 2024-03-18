import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/workflows/user_workflow_step_execution_run.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';

class RunWidget extends StatefulWidget {
  final UserWorkflowStepExecutionRun run;
  const RunWidget({required this.run, Key? key}) : super(key: key);

  @override
  State<RunWidget> createState() => _RunWidgetState();
}

class _RunWidgetState extends State<RunWidget> {
  final double indicatorSize = 15;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final doneIndicator = DotIndicator(
      border: Border.all(
        color: ds.DesignColor.primary.main,
        width: 2.0,
      ),
      color: ds.DesignColor.primary.main,
      child: ds.DesignIcon.check(size: indicatorSize),
    );

    final runningIndicator = OutlinedDotIndicator(
      color: ds.DesignColor.primary.main,
      child: ds.DesignIcon.moreVertical(
          size: indicatorSize,
          color: ds.DesignColor.primary.main,
          rotationAngle: pi / 2),
    );

    final notDoneIndicator = OutlinedDotIndicator(
      color: themeProvider.themeMode == ThemeMode.dark
          ? ds.DesignColor.grey.grey_5
          : ds.DesignColor.grey.grey_3,
      child: ds.DesignIcon.check(
        size: indicatorSize,
        color: Colors.transparent,
      ),
    );

    final indicator;
    if (widget.run.validated) {
      indicator = doneIndicator;
    } else if (widget.run.started) {
      indicator = runningIndicator;
    } else {
      indicator = notDoneIndicator;
    }

    print("Widget.run.validated: ${widget.run.validated}");
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.smallPadding),
      child: Container(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(ds.Spacing.smallPadding),
                      child: indicator,
                    ),
                    Flexible(
                      child: Text(
                        widget.run.parameter.toString(),
                        style: TextStyle(fontSize: ds.TextFontSize.body2),
                      ),
                    ),
                  ],
                ),
                if (widget.run.result != null)
                  Padding(
                    padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                    child: Text(
                      widget.run.result!.toString(),
                      style: TextStyle(fontSize: ds.TextFontSize.body2),
                    ),
                  ),
                if (widget.run.result != null && !widget.run.validated)
                  RunValidationWidget(
                    onValidate: () async {
                      bool success = await widget.run.validate();
                      if (success) {
                        setState(() {});
                      }
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RunValidationWidget extends StatelessWidget {
  final Function() onValidate;
  const RunValidationWidget({required this.onValidate, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        Expanded(
          child: ds.Button.fill(
            text: "Reject",
            padding: const EdgeInsets.all(ds.Spacing.smallPadding),
            onPressed: () {},
            textColor: ds.DesignColor.primary.main,
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_1
                : ds.DesignColor.grey.grey_1,
          ),
        ),
        ds.Space.horizontalSmall,
        Expanded(
          child: ds.Button.fill(
              text: "Validate",
              padding: EdgeInsets.all(ds.Spacing.smallPadding),
              onPressed: onValidate),
        )
      ],
    );
  }
}