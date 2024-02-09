import 'package:flutter/material.dart';

import '../../../../DS/design_system.dart' as ds;

class VoiceMessageCheck extends StatelessWidget {
  final bool active;

  const VoiceMessageCheck({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.only(right: ds.Spacing.smallPadding),
            child: Icon(Icons.check,
                color: active ? Colors.green : Colors.white24)));
  }
}
