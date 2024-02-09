import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;

class MessageFailed extends StatelessWidget {
  final Function() onResubmit;

  MessageFailed({super.key, required this.onResubmit});

  @override
  Widget build(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return GestureDetector(
      onTap: () => onResubmit(),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: ds.Spacing.base),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: ds.DesignColor.status.error),
          child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(
                  vertical: ds.Spacing.base,
                  horizontal: ds.Spacing.smallPadding),
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ds.Spacing.smallPadding),
                  child: Row(
                    children: [
                      const Icon(Icons.restart_alt, color: Colors.white),
                      Expanded(
                        child: Text(
                            labelsProvider.getText(
                                key: "errorMessages.messageFailedEmission"),
                            style: const TextStyle(color: Colors.white),
                            textScaleFactor: 1.05,
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
