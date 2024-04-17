import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../role_manager/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final Widget? child;

  ProfileCard({required this.profile, this.child, Key? key}) : super(key: key);

  String getUsageLimitText(labelsProvider) {
    String text = "";
    if (profile.nValidityDays != null) {
      text +=
          "\n\n- ${profile.nValidityDays} ${labelsProvider.getText(key: "plan.productCard.nValidityDaysSuffix")}";
    }
    if (profile.nTasksLimit != null) {
      text +=
          "\n\n- ${profile.nTasksLimit} ${labelsProvider.getText(key: "plan.productCard.nTasksLimitSuffix")}";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: themeProvider.themeMode == ThemeMode.dark
          ? ds.DesignColor.grey.grey_7
          : ds.DesignColor.grey.grey_1,
      child: Padding(
        padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
        child: Column(
          children: [
            Text(
              profile.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ds.TextFontSize.h5,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_1
                      : ds.DesignColor.grey.grey_9),
            ),
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.smallPadding),
              child: Divider(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_3
                    : ds.DesignColor.grey.grey_9,
              ),
            ),
            Text(
              profile.description,
              style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_3
                      : ds.DesignColor.grey.grey_9,
                  fontSize: ds.TextFontSize.body2),
            ),
            ds.Space.verticalLarge,
            if (profile.nValidityDays != null || profile.nTasksLimit != null)
              Text(
                "\n${labelsProvider.getText(key: "plan.productCard.usageLimitTitle")} ${getUsageLimitText(labelsProvider)}",
                style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? ds.DesignColor.grey.grey_3
                        : ds.DesignColor.grey.grey_9,
                    fontSize: ds.TextFontSize.body2),
              ),
            ds.Space.verticalLarge,
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
