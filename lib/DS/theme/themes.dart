import 'package:flutter/material.dart';

import '../../src/models/user/user.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load the saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final savedThemeMode = User().themeMode;
    if (savedThemeMode == 'dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  // Save the selected theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    User().themeMode = themeMode.toString().split('.').last;
  }

  // Define the setTheme method to update the theme mode
  void setTheme(ThemeMode newThemeMode) {
    themeMode = newThemeMode;
    notifyListeners();
    // Save the selected theme mode
    _saveThemeMode();
  }
}
