import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/DS/theme/themes.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

class ProgressIndicatorView extends StatelessWidget {
  final Logger logger = Logger('OnboardingProgressIndicatorView');

  ProgressIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      automaticallyImplyLeading: false,
      appBarTitle: "",
      safeAreaOverflow: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ds.Spacing.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                    child: Text(
                      labelsProvider.getText(
                          key: "onboarding.progressIndicatorPage.emoji"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: ds.TextFontSize.h1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                    child: Text(
                      labelsProvider.getText(
                          key: "onboarding.progressIndicatorPage.title"),
                      style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_9,
                          fontSize: ds.TextFontSize.h2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                    child: Text(
                      labelsProvider.getText(
                          key: "onboarding.progressIndicatorPage.body"),
                      style: TextStyle(
                          color: ds.DesignColor.grey.grey_3,
                          fontSize: ds.TextFontSize.body2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: ds.Spacing.largeSpacing),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        color: ds.DesignColor.primary.main,
                        backgroundColor:
                            themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_7
                                : ds.DesignColor.grey.grey_3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
