import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  // ✅ Getter-kan asalka ah (isDark)
  bool get isDark => _isDark;

  // ✅ FIX: Getter-kan ayaan ku daray si ProfileScreen u garato (isDarkMode)
  bool get isDarkMode => _isDark;

  ThemeMode get themeMode =>
      _isDark ? ThemeMode.dark : ThemeMode.light;

  // 🔄 Toggle theme
  Future<void> toggleTheme() async {
    _isDark = !_isDark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark);

    notifyListeners();
  }

  // 🎯 Set specific mode
  Future<void> setDarkMode(bool value) async {
    _isDark = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark);

    notifyListeners();
  }

  // 📥 Load saved theme (marka app-ka furmo)
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDark = prefs.getBool('is_dark') ?? true;

    notifyListeners();
  }
}