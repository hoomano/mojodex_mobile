import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/widgets/correctable_text.dart';

import '../../../../DS/design_system.dart' as ds;

class VoiceMessageText extends StatelessWidget {
  final String text;
  final Color textColor;
  final Function(String) correctSpell;
  final bool streaming;

  VoiceMessageText(
      {super.key,
      required this.text,
      required this.textColor,
      required this.correctSpell,
      required this.streaming});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(
          vertical: ds.Spacing.base, horizontal: ds.Spacing.smallPadding),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: ds.Spacing.smallPadding),
            child: Align(
                alignment: Alignment.centerLeft,
                child: CorrectableText(
                    text: text,
                    textColor: textColor,
                    onTap: correctSpell,
                    editable: !streaming,
                    fontSize: ds.TextFontSize.body2))),
      ),
    );
  }
}
