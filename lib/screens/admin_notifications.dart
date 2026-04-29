import 'package:flutter/material.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  // Dummy notifications (waxaad beddeli kartaa markii backend jirto)
  final List<Map<String, String>> notifications = [
    {
      "title": "Order cusub",
      "message": "Macmiil cusub ayaa dalbaday product."
    },
    {
      "title": "Delivery request",
      "message": "Driver cusub ayaa codsaday shaqo."
    },
    {
      "title": "System update",
      "message": "App-ka waa la update gareeyay."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Notifications"),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(item["title"] ?? ""),
                    subtitle: Text(item["message"] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          notifications.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}