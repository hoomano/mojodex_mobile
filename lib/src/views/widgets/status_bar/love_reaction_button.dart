import 'package:flutter/material.dart';

import '../../../../DS/design_system.dart' as ds;

class LoveReactionButton extends StatefulWidget {
  final Function onLove;
  const LoveReactionButton({required this.onLove, Key? key}) : super(key: key);

  @override
  State<LoveReactionButton> createState() => _LoveReactionButtonState();
}

class _LoveReactionButtonState extends State<LoveReactionButton> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_selected) return;
        setState(() {
          _selected = true;
        });
        widget.onLove();
      },
      child: ds.DesignIcon.heart01(
        color: _selected
            ? ds.DesignColor.status.error
            : ds.DesignColor.grey.grey_3,
        size: ds.TextFontSize.h3,
      ),
    );
  }
}
