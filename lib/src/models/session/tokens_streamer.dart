import 'dart:async';

class TokenStreamer {
  static final StreamController<String?> _mojoTokenController =
      StreamController.broadcast();

  Stream<String?> get mojoTokenStream {
    return _mojoTokenController.stream;
  }

  static final StreamController<Map<String, String>?> _draftTokenController =
      StreamController.broadcast();

  Stream<Map<String, String>?> get draftTokenStream {
    return _draftTokenController.stream;
  }
}
