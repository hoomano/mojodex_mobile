import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/language/system_language.dart';
import '../../../models/workflows/user_worklow_execution.dart';
import '../../widgets/correctable_text.dart';

class ResultView extends StatelessWidget {
  final UserWorkflowExecution userWorkflowExecution;
  const ResultView({Key? key, required this.userWorkflowExecution})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: CorrectableText(
                text: userWorkflowExecution.producedText?.title ?? "",
                textColor: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_1
                    : ds.DesignColor.grey.grey_9,
                fontSize: ds.TextFontSize.h3,
                textAlign: TextAlign.start,
                editable: false,
                onTap: (textToCorrect) {})),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: ds.Spacing.smallPadding),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            color: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_7
                : ds.DesignColor.grey.grey_1,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(ds.Spacing.largePadding),
                    child: CorrectableText(
                        text: userWorkflowExecution.producedText?.production ??
                            "",
                        textColor: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_1
                            : ds.DesignColor.grey.grey_9,
                        fontSize: ds.TextFontSize.body2,
                        height: 1.6,
                        editable: false,
                        onTap: (textToCorrect) {})),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
