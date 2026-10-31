import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'light';

    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'themeMode',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }
}
