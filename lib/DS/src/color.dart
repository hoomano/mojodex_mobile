part of design_system;

class _Primary {
  const _Primary();

  final Color main = const Color(0xFF3763e7);
  final Color dark = const Color(0xFF1d52bf);
  final Color light = const Color(0xFF86adff);
}

class _Gray {
  const _Gray();

  final Color grey_1 = const Color(0xFFf3f4f6);
  final Color grey_3 = const Color(0xFF879BB7);
  final Color grey_5 = const Color(0xFF4C5563);
  final Color grey_7 = const Color(0xFF1F2937);
  final Color grey_9 = const Color(0xFF000000);
}

class _Status {
  const _Status();

  final Color success = const Color(0xFF28A745);
  final Color successSecondary = const Color(0xFFCAE5D3);
  final Color error = const Color(0xFFDC3545);
  final Color errorSecondary = const Color(0xFFF5EAC6);
  final Color warning = const Color(0xFFFFC107);
  final Color warningSecondary = const Color(0x33FFC107);
}

class DesignColor {
  const DesignColor();

  // ignore: library_private_types_in_public_api
  static const _Primary primary = _Primary();

  // ignore: library_private_types_in_public_api
  static const _Gray grey = _Gray();

  // ignore: library_private_types_in_public_api
  static const _Status status = _Status();
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
