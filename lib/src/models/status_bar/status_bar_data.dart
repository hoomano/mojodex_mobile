import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

class StatusBarData {
  final Logger logger = Logger('StatusBarData');

  // Unique instance of the class
  static final StatusBarData _instance = StatusBarData.privateConstructor();

  // Private constructor of the class, called once when the class is created
  StatusBarData.privateConstructor();

  factory StatusBarData() => _instance;

  // ValueNotifier to notify the UI when the status bar height changes
  final ValueNotifier<double> _finalHeight = ValueNotifier<double>(350);
  ValueNotifier<double> get finalHeight => _finalHeight;

  // ValueNotifier to notify the UI when the status bar must be displayed or
  final ValueNotifier<bool> _displayed = ValueNotifier<bool>(false);
  ValueNotifier<bool> get displayed => _displayed;

  String? text;

  bool expanded = false;
}
