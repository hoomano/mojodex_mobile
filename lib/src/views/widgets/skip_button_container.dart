import 'package:flutter/material.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/DS/theme/themes.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

class SkipButtonContainer extends StatelessWidget {
  final Widget? child;
  final void Function()? onSkipPressed;

  SkipButtonContainer({Key? key, this.child, this.onSkipPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: child ?? Container()),
        Padding(
          padding: EdgeInsets.only(
            // If the keyboard pop ups MediaQuery.of(context).viewPadding.bottom allows
            // to leave the content in the same place on screen
            bottom: ds.Spacing.smallSpacing +
                MediaQuery.of(context).viewPadding.bottom,
            top: ds.Spacing.smallSpacing,
            right: ds.Spacing.smallSpacing,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ds.Button.outline(
                backgroundColor: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_9
                    : ds.DesignColor.white,
                text: labelsProvider.getText(key: "skipContainerButton"),
                onPressed: onSkipPressed,
              ),
            ],
          ),
        )
      ],
    );
  }
}
