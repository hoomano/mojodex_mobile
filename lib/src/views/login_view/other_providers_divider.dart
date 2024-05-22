import 'package:flutter/material.dart';

import '../../../DS/design_system.dart' as ds;

class OtherProvidersDivider extends StatelessWidget {
  const OtherProvidersDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ds.Spacing.largePadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(
              color: ds.DesignColor.grey.grey_1,
              //height: 36,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ds.Spacing.smallPadding),
            child: Text("Or continue with"),
          ),
          Expanded(
            child: Divider(
              color: ds.DesignColor.grey.grey_1,
            ),
          ),
        ],
      ),
    );
  }
}
