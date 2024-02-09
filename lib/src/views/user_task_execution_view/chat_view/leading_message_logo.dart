import 'package:flutter/material.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../constants/constants.dart';

class LeadingMessageLogo extends StatelessWidget {
  final bool sentByUser;

  const LeadingMessageLogo({super.key, required this.sentByUser});

  @override
  Widget build(BuildContext context) {
    if (!sentByUser) {
      return Padding(
        padding: const EdgeInsets.all(ds.Spacing.smallPadding),
        // rounded image of path Constants.logoPath size 40x40
        child: SizedBox(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(Constants.logoPath),
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(ds.Spacing.smallPadding),
      child: SizedBox(height: 40, width: 40),
    );
  }
}
