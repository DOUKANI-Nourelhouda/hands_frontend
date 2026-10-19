import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const List<String> supportedLanguages = ['en', 'ar', 'fr'];

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language');

    if (saved != null && supportedLanguages.contains(saved)) {
      _locale = Locale(saved);
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    if (!supportedLanguages.contains(langCode)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    _locale = Locale(langCode);
    notifyListeners();
  }
}
