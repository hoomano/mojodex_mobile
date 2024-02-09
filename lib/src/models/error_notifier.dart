import 'dart:async';

import 'package:logging/logging.dart';

class ErrorNotifier {
  // Logger
  final Logger logger = Logger('ErrorNotifier');

  // Unique instance of the class
  static final ErrorNotifier _instance = ErrorNotifier.privateConstructor();

  // Private constructor of the class, called once when the class is created
  ErrorNotifier.privateConstructor();

  factory ErrorNotifier() => _instance;

  // Stream controller to notify of errors
  final StreamController<String?> errorController =
      StreamController.broadcast();
  Stream<String?> get errorStream => errorController.stream;

  void consumeError() {
    errorController.add(null);
  }
}
