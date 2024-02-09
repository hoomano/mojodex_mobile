import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/session/task_session.dart';
import '../../../speaker.dart';

class ValidationWidget extends StatefulWidget {
  final TaskSession session;
  final Function onValidate;
  ValidationWidget({required this.session, required this.onValidate});

  @override
  State<ValidationWidget> createState() => _ValidationWidgetState();
}

class _ValidationWidgetState extends State<ValidationWidget> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    bool darkTheme = themeProvider.themeMode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.smallPadding),
      child: _processing
          ? LinearProgressIndicator(
              color: ds.DesignColor.primary.main,
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? ds.DesignColor.grey.grey_7
                  : ds.DesignColor.grey.grey_3,
            )
          : Row(
              children: [
                Expanded(
                    child: ds.Button.fill(
                  text:
                      labelsProvider.getText(key: "validationWidget.noButton"),
                  padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                  onPressed: () {
                    widget.session.refuseTaskToolExecution();
                  },
                  textColor: ds.DesignColor.primary.main,
                  backgroundColor: darkTheme
                      ? ds.DesignColor.grey.grey_1
                      : ds.DesignColor.grey.grey_1,
                )),
                ds.Space.horizontalMedium,
                Expanded(
                    child: ds.Button.fill(
                  text:
                      labelsProvider.getText(key: "validationWidget.okButton"),
                  padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                  onPressed: () async {
                    setState(() {
                      _processing = true;
                    });
                    await Speaker().currentPlayingAudioManager?.pause();
                    bool success =
                        await widget.session.acceptTaskToolExecution();
                    if (success) {
                      widget.onValidate();
                    } else {
                      // If HTTP call fails ???
                      // 1. Remove 'waiting for mojo'
                      widget.session.waitingForMojo = false;
                      // 2. Remove user_message
                      widget.session.removeLastUserMessage();
                      widget.session.messages[0]
                          .taskToolExecutionAcceptedByUser = null;
                      // 3. Reset choice widget
                      setState(() {
                        _processing = false;
                      });
                    }
                    // on click pop-up, pop context
                  },
                ))
              ],
            ),
    );
  }
}
