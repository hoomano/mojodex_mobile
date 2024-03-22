import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/workflows/user_workflow_step_execution.dart';

class RunWidget extends StatefulWidget {
  final UserWorkflowStepExecution stepExecution;
  final Function() onReject;
  const RunWidget(
      {required this.stepExecution, required this.onReject, Key? key})
      : super(key: key);

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
    if (widget.stepExecution.validated) {
      indicator = doneIndicator;
    } else if (widget.stepExecution.result == null ||
        (widget.stepExecution.result != null &&
            !widget.stepExecution.validated)) {
      indicator = runningIndicator;
    } else {
      indicator = notDoneIndicator;
    }

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
                        widget.stepExecution.parameter.toString(),
                        style: TextStyle(fontSize: ds.TextFontSize.body2),
                      ),
                    ),
                  ],
                ),
                if (widget.stepExecution.result != null)
                  Padding(
                    padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ds.DesignColor.grey.grey_3,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.stepExecution.result!
                                .map(
                                  (r) => Text(
                                    r.toString(),
                                    style: TextStyle(
                                        fontSize: ds.TextFontSize.body2),
                                  ),
                                )
                                .toList()),
                      ),
                    ),
                  ),
                if (widget.stepExecution.result != null &&
                    !widget.stepExecution.validated)
                  RunValidationWidget(
                    onReject: () async {
                      // option 1: retourner sur le chat => Mais un peu trompeur pour le user: ça laisse penser qu'on peut demander n'importe quoi dans le chat
                      bool success = await widget.stepExecution.invalidate();
                      widget.onReject();

                      // option 2: invalider le run => Pour le debug
                      //bool success = await widget.run.invalidate();

                      // option 3: ouvrir un mini-chat ici même pour obtenir les précisions nécessaires
                    },
                    onValidate: () async {
                      bool success = await widget.stepExecution.validate();
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
  final Function() onReject;
  const RunValidationWidget(
      {required this.onValidate, required this.onReject, Key? key})
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
            onPressed: onReject,
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
