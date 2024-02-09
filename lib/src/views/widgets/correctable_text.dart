import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextPortion {
  String text;
  bool isEditable;

  TextPortion(this.text, this.isEditable);
}

class CorrectableText extends StatelessWidget {
  final String text;
  final Color textColor;
  late List<TextPortion> textPortions;
  final Function(String) onTap;
  final double fontSize;
  final double? height;
  final TextAlign textAlign;
  final bool editable;

  CorrectableText(
      {required this.text,
      required this.textColor,
      required this.onTap,
      required this.fontSize,
      required this.editable,
      this.height,
      this.textAlign = TextAlign.start,
      Key? key})
      : super(key: key) {
    textPortions = _cutTextToSeparateUnsureSpellings(text);
  }

  List<TextPortion> _cutTextToSeparateUnsureSpellings(String inputText) {
    List<TextPortion> result = [];
    RegExp isEditableRegex = RegExp(r'\*(.*?)\*');

    int startIndex = 0;
    for (Match match in isEditableRegex.allMatches(inputText)) {
      // Add text before the match
      result.add(
          TextPortion(inputText.substring(startIndex, match.start), false));

      // Add the matched text without the '**', or an empty string if match.group(1) is null
      result.add(TextPortion(match.group(1) ?? '', true));

      // Update the start index for the next iteration
      startIndex = match.end;
    }

    // Add the remaining text after the last match
    result.add(TextPortion(inputText.substring(startIndex), false));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: textPortions
            .map(
              (portion) => TextSpan(
                text: portion.text,
                recognizer: TapGestureRecognizer()
                  ..onTap = (portion.isEditable && editable)
                      ? () => onTap(portion.text)
                      : null,
                style: TextStyle(
                  fontSize: fontSize,
                  decoration: (portion.isEditable && editable)
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: textColor,
                  height: height,
                  color: textColor,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
