import 'package:flutter/widgets.dart';

import 'leading_message_logo.dart';

class MessageContainer extends StatelessWidget {
  final Alignment alignment;
  final bool hasLeading;
  final Widget child;

  const MessageContainer(
      {required this.child,
      this.alignment = Alignment.centerLeft,
      this.hasLeading = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.80,
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LeadingMessageLogo(sentByUser: hasLeading),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
