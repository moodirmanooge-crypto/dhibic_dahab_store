import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Ma hubtaa inaad account-ka ka baxeyso?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Successfully logged out",
                    ),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                fontSize: 18,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("English 🇬🇧"),
            onTap: () {
              langProvider.setLocale(
                const Locale("en"),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Somali 🇸🇴"),
            onTap: () {
              langProvider.setLocale(
                const Locale("so"),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Arabic 🇸🇦"),
            onTap: () {
              langProvider.setLocale(
                const Locale("ar"),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Turkish 🇹🇷"),
            onTap: () {
              langProvider.setLocale(
                const Locale("tr"),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("German 🇩🇪"),
            onTap: () {
              langProvider.setLocale(
                const Locale("de"),
              );
            },
          ),

          const Divider(),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: themeProvider.isDark,
            onChanged: (v) {
              themeProvider.toggleTheme();
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}