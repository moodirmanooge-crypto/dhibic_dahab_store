import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {

  Locale _locale = const Locale("en");

  Locale get locale => _locale;

  void setLocale(Locale locale) async {

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", locale.languageCode);

    notifyListeners();

  }

  void loadLanguage() async {

    final prefs = await SharedPreferences.getInstance();

    String lang = prefs.getString("language") ?? "en";

    _locale = Locale(lang);

    notifyListeners();

  }

}