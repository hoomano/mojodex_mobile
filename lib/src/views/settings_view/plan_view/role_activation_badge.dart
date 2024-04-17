import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;

class RoleActivationBadge extends StatelessWidget {
  final bool active;
  RoleActivationBadge({required this.active, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Badge(
      backgroundColor: active
          ? ds.DesignColor.status.successSecondary
          : ds.DesignColor.status.errorSecondary,
      largeSize: ds.TextFontSize.body2 * 2,
      padding: const EdgeInsets.symmetric(
          horizontal: ds.Spacing.mediumPadding,
          vertical: ds.Spacing.smallPadding),
      label: Text(
          active
              ? labelsProvider.getText(key: "plan.purchaseBadge.activeState")
              : labelsProvider.getText(key: "plan.purchaseBadge.expiredState"),
          style: TextStyle(
              fontSize: ds.TextFontSize.body2,
              color: active
                  ? ds.DesignColor.status.success
                  : ds.DesignColor.status.error)),
    );
  }
}
