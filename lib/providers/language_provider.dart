import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default waa English

  Locale get locale => _locale;

  void setLocale(Locale type) async {
    _locale = type;
    notifyListeners(); // ✅ Waxay ku amraysaa app-ka inuu dib u dhismo (Rebuild)

    // Kaydi luqadda
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', type.languageCode);
  }

  void loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('language_code') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }
}