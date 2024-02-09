import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../purchase_manager/purchase.dart';

class PurchaseUsage extends StatelessWidget {
  final Purchase purchase;

  PurchaseUsage({required this.purchase, Key? key}) : super(key: key);

  String getUsageLimitText(labelsProvider) {
    String text = "";
    if (purchase.product.nValidityDays != null) {
      text +=
          "\n\n 🗓️ ${purchase.remainingDays} ${labelsProvider.getText(key: "plan.purchaseUsageCard.remainingDaysSuffix")}";
    }
    if (purchase.product.nTasksLimit != null) {
      text +=
          "\n\n ✓ ${purchase.nTasksConsumed}/${purchase.product.nTasksLimit} ${labelsProvider.getText(key: "plan.purchaseUsageCard.nTasksLimitSuffix")}";
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
