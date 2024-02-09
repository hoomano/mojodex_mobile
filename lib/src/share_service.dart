import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

/// Shared class that contains shared methods
/// that can be used in the whole app
class ShareService {
  /// Calculate the position of the share button on the screen
  /// based on the [key] of the widget that will be used to calculate the position
  static Rect _shareButtonRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset position = renderBox.localToGlobal(Offset.zero);

    return Rect.fromCenter(
      center: position + Offset(size.width * 0.5, size.height * 0.5),
      width: size.width,
      height: size.height,
    );
  }

  /// Share text and subject with other apps
  /// [key] is the key of the widget that will be used to calculate the position
  /// of the share button on the screen neccessary for the share plugin on Ipads
  /// [text] is the text to share
  /// [subject] is the subject of the text to share
  static void share(
      {required GlobalKey key, required String text, required String subject}) {
    try {
      Share.share(
        text,
        subject: subject,
        sharePositionOrigin: _shareButtonRect(key),
      );
    } catch (e) {
      Logger('ShareService').shout("Error in share method: $e");
    }
  }
}
