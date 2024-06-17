import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/product_card.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/purchase_activation_badge.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/purchase_usage.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../purchase_manager/purchase_manager.dart';

class PlanView extends StatelessWidget {
  static String routeName = "plan";
  final Logger logger = Logger('PlanView');

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
        appBarTitle: labelsProvider.getText(key: "plan.appBarTitle"),
        safeAreaOverflow: false,
        body: Consumer<PurchaseManager>(
            builder: (context, purchaseManager, child) {
          List<Widget> currentPurchases = purchaseManager.currentPurchases!
              .map((purchase) => ProductCard(
                    product: purchase.product,
                    child: Column(
                      children: [
                        PurchaseActivationBadge(active: true),
                        ds.Space.verticalLarge,
                        if (purchase.product.nValidityDays != null &&
                            purchase.product.nTasksLimit != null)
                          PurchaseUsage(purchase: purchase)
                      ],
                    ),
                  ))
              .toList();

          List<Widget> expiredPurchases =
              purchaseManager.expiredPurchases == null
                  ? []
                  : purchaseManager.expiredPurchases!
                      .map((purchase) => ProductCard(
                            product: purchase.product,
                            child: PurchaseActivationBadge(active: false),
                          ))
                      .toList();

          List<Widget> purchasableProducts = purchaseManager.purchasableProducts
              .map((product) => ProductCard(product: product))
              .toList();

          return Center(
            child: Padding(
                padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          labelsProvider.getText(key: "plan.title"),
                          style: TextStyle(
                            fontSize: ds.TextFontSize.h3,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_1
                                : ds.DesignColor.grey.grey_9,
                          ),
                        ),
                        ds.Space.verticalLarge,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            labelsProvider.getText(key: "plan.currentPlans"),
                            style: TextStyle(
                              fontSize: ds.TextFontSize.h3,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_1
                                  : ds.DesignColor.grey.grey_9,
                            ),
                          ),
                        ),
                        ds.Space.verticalLarge,
                      ]
                        ..addAll(currentPurchases)
                        ..addAll(expiredPurchases)
                        ..addAll([
                          ds.Space.verticalLarge,
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              labelsProvider.getText(key: "plan.updatePlan"),
                              style: TextStyle(
                                fontSize: ds.TextFontSize.h3,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9,
                              ),
                            ),
                          ),
                          ds.Space.verticalLarge,
                        ])
                        ..addAll(purchasableProducts)),
                )),
          );
        }));
  }
}
