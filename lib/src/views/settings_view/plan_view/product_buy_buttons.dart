import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/purchase_manager/product.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';

class ProductBuyButtons extends StatelessWidget {
  final Product product;
  final String price;
  final Function onBuyNowPressed;
  final Function onContactUs;

  const ProductBuyButtons(
      {required this.product,
      required this.price,
      required this.onBuyNowPressed,
      required this.onContactUs,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        ds.Button.fill(
            onPressed: () => onBuyNowPressed(),
            text: product.isSubscription && !product.isPackage
                ? "Subscribe for $price per month"
                : "Buy now for $price"),
        if (product.isSubscription)
          Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: Column(
              children: [
                Text(
                  "Or, if you want a custom plan",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: ds.TextFontSize.body2,
                      color: ds.DesignColor.grey.grey_3),
                ),
                Padding(
                  padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                  child: ds.Button.fill(
                      onPressed: () => onContactUs(), text: "Contact us"),
                ),
                Text(
                  "People usually contact us to get a quote",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: ds.TextFontSize.body2,
                      color: ds.DesignColor.grey.grey_3),
                )
              ],
            ),
          )
      ],
    );
  }
}
