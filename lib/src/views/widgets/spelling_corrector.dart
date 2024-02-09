import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';

class SpellingCorrector extends StatelessWidget {
  final focusNode = FocusNode();

  late TextEditingController _textEditingController;
  Function(String) onFinishSpellingCorrection;
  Function() onDismissed;

  SpellingCorrector(
      {required String text,
      required this.onFinishSpellingCorrection,
      required this.onDismissed,
      Key? key})
      : super(key: key) {
    _textEditingController = TextEditingController(text: text);
  }

  @override
  Widget build(BuildContext context) {
    // open keyboard
    FocusScope.of(context).requestFocus(focusNode);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: EdgeInsets.all(ds.Spacing.mediumPadding),
      padding: EdgeInsets.all(ds.Spacing.base),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: themeProvider.themeMode == ThemeMode.dark
                  ? ds.DesignColor.grey.grey_7
                  : ds.DesignColor.grey.grey_1)),
      child: SizedBox(
        height: 25,
        child: TextFormField(
          controller: _textEditingController,
          onTapOutside: (event) {
            onDismissed();
            focusNode.unfocus();
          },
          cursorColor: ds.DesignColor.primary.main,
          focusNode: focusNode,
          style: TextStyle(
            color: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_1
                : ds.DesignColor.grey.grey_9,
          ),
          decoration: InputDecoration(
              prefix: ds.Space.horizontalSmall,
              border: InputBorder.none,
              suffixIcon: InkWell(
                  onTap: () {
                    onFinishSpellingCorrection(_textEditingController.text);
                    focusNode.unfocus();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ds.DesignColor.primary.main,
                        )),
                    child: ds.DesignIcon.check(
                        size: 10, color: ds.DesignColor.primary.main),
                  ))),
          onFieldSubmitted: (value) {
            onFinishSpellingCorrection(_textEditingController.text);
            focusNode.unfocus();
          },
        ),
      ),
    );
  }
}
