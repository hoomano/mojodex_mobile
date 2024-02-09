import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/mojodex_app.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';

// This view is displayed when app can't be launched due to lack of internet connection or any backend error
class NoConnectionErrorView extends StatefulWidget {
  final bool isInternetConnectionError;
  const NoConnectionErrorView(
      {required this.isInternetConnectionError, super.key});

  @override
  State<NoConnectionErrorView> createState() => _NoConnectionErrorViewState();
}

class _NoConnectionErrorViewState extends State<NoConnectionErrorView> {
  final Logger logger = Logger('NoConnectionErrorView');
  bool retryButtonPressed = false;

  onRetryButtonPressed() async {
    setState(() => retryButtonPressed = true);

    // Run app if language is set
    try {
      await User().login();
    } on SocketException catch (e) {
      setState(() {
        retryButtonPressed = false;
      });
      return;
    }
    return runApp(MojodexApp());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: widget.isInternetConnectionError
                ? Stack(alignment: Alignment.center, children: [
                    ds.DesignIcon.cloud(color: ds.DesignColor.primary.light),
                    ds.DesignIcon.closeLG(color: ds.DesignColor.primary.main)
                  ])
                : ds.DesignIcon.triangleWarning(
                    color: ds.DesignColor.primary.light),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ds.Spacing.mediumSpacing,
                vertical: ds.Spacing.mediumSpacing),
            child: Text(
              widget.isInternetConnectionError
                  ? "Oops, It seems you don't have internet connection"
                  : "Oops, something went wrong - Please try again",
              style: TextStyle(fontSize: ds.TextFontSize.h5),
            ),
          ),
          ds.Button.fill(
            text: "Retry",
            onPressed: retryButtonPressed ? null : onRetryButtonPressed,
          )
        ],
      ),
    ));
  }
}
