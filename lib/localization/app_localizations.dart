import 'package:flutter/material.dart';

class AppLocalizations {

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context){

    return Localizations.of<AppLocalizations>(
        context,
        AppLocalizations)!;

  }

  static const Map<String, Map<String, String>> _localizedValues = {

    "en":{

      "settings":"Settings",
      "profile":"Profile",
      "products":"Products",
      "home":"Home",
      "categories":"Categories",
      "reading":"Reading",
      "exchange":"Exchange",
      "my_orders":"My Orders"

    },

    "so":{

      "settings":"Dejinta",
      "profile":"Akoon",
      "products":"Alaab",
      "home":"Bogga Hore",
      "categories":"Qaybaha",
      "reading":"Akhris",
      "exchange":"Isweydaarsi",
      "my_orders":"Dalabyadayda"

    },

    "ar":{

      "settings":"الإعدادات",
      "profile":"الملف الشخصي",
      "products":"المنتجات",
      "home":"الرئيسية",
      "categories":"الفئات",
      "reading":"القراءة",
      "exchange":"التبادل",
      "my_orders":"طلباتي"

    },

    "tr":{

      "settings":"Ayarlar",
      "profile":"Profil",
      "products":"Ürünler",
      "home":"Ana Sayfa",
      "categories":"Kategoriler",
      "reading":"Okuma",
      "exchange":"Değişim",
      "my_orders":"Siparişlerim"

    },

    "de":{

      "settings":"Einstellungen",
      "profile":"Profil",
      "products":"Produkte",
      "home":"Startseite",
      "categories":"Kategorien",
      "reading":"Lesen",
      "exchange":"Austausch",
      "my_orders":"Meine Bestellungen"

    }

  };

  String translate(String key){

    return _localizedValues[locale.languageCode]![key]!;

  }

}