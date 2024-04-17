import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../role_manager/role.dart';

class RoleUsage extends StatelessWidget {
  final Role role;

  RoleUsage({required this.role, Key? key}) : super(key: key);

  String getUsageLimitText(labelsProvider) {
    String text = "";
    if (role.profile.nValidityDays != null) {
      text +=
          "\n\n 🗓️ ${role.remainingDays} ${labelsProvider.getText(key: "plan.purchaseUsageCard.remainingDaysSuffix")}";
    }
    if (role.profile.nTasksLimit != null) {
      text +=
          "\n\n ✓ ${role.nTasksConsumed}/${role.profile.nTasksLimit} ${labelsProvider.getText(key: "plan.purchaseUsageCard.nTasksLimitSuffix")}";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.smallPadding),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_5
            : ds.DesignColor.white,
        child: Padding(
          padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
          child: Column(
            children: [
              Text(labelsProvider.getText(key: "plan.purchaseUsageCard.title"),
                  style: TextStyle(
                      fontSize: ds.TextFontSize.h5,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9)),
              Text(getUsageLimitText(labelsProvider),
                  style: TextStyle(
                      fontSize: ds.TextFontSize.body2,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9)),
            ],
          ),
        ),
      ),
    );
  }
}
