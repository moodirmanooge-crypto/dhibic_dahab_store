import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text("Ku dar Product"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Maamul Categories"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text("Delivery Settings"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
