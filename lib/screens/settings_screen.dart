import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    var langProvider =
        Provider.of<LanguageProvider>(context);

    var themeProvider =
        Provider.of<ThemeProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(

        children: [

          const ListTile(
            title: Text(
              "Select Language",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:18,
              ),
            ),
          ),

          ListTile(
            title: const Text("English 🇬🇧"),
            onTap: (){
              langProvider.setLocale(const Locale("en"));
            },
          ),

          ListTile(
            title: const Text("Somali 🇸🇴"),
            onTap: (){
              langProvider.setLocale(const Locale("so"));
            },
          ),

          ListTile(
            title: const Text("Arabic 🇸🇦"),
            onTap: (){
              langProvider.setLocale(const Locale("ar"));
            },
          ),

          ListTile(
            title: const Text("Turkish 🇹🇷"),
            onTap: (){
              langProvider.setLocale(const Locale("tr"));
            },
          ),

          ListTile(
            title: const Text("German 🇩🇪"),
            onTap: (){
              langProvider.setLocale(const Locale("de"));
            },
          ),

          const Divider(),

          SwitchListTile(

            title: const Text("Dark Mode"),

            value: themeProvider.isDark,

            onChanged: (v){

              themeProvider.toggleTheme();

            },

          ),

        ],

      ),

    );

  }

}