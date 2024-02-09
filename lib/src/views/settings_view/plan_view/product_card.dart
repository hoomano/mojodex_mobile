import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../purchase_manager/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Widget? child;

  ProductCard({required this.product, this.child, Key? key}) : super(key: key);

  String getUsageLimitText(labelsProvider) {
    String text = "";
    if (product.nValidityDays != null) {
      text +=
          "\n\n- ${product.nValidityDays} ${labelsProvider.getText(key: "plan.productCard.nValidityDaysSuffix")}";
    }
    if (product.nTasksLimit != null) {
      text +=
          "\n\n- ${product.nTasksLimit} ${labelsProvider.getText(key: "plan.productCard.nTasksLimitSuffix")}";
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
              product.name,
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
              product.description,
              style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_3
                      : ds.DesignColor.grey.grey_9,
                  fontSize: ds.TextFontSize.body2),
            ),
            ds.Space.verticalLarge,
            if (product.nValidityDays != null || product.nTasksLimit != null)
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
