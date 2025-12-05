import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isGoldTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get isGoldTheme => _isGoldTheme;

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isGoldTheme = prefs.getBool('isGoldTheme') ?? true;
      notifyListeners();
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleGoldTheme() async {
    _isGoldTheme = !_isGoldTheme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGoldTheme', _isGoldTheme);
    } catch (e) {
      // Handle error
    }
  }
}