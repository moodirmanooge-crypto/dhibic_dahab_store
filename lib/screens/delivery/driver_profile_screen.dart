import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverProfileScreen extends StatefulWidget {
  final String driverId;

  const DriverProfileScreen({super.key, required this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Profile 👤")),

      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('drivers')
            .doc(widget.driverId)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          bool completed = data['profileCompleted'] ?? false;

          nameController.text = data['name'] ?? "";

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Driver Name",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !completed,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: completed ? null : () async {

                    await FirebaseFirestore.instance
                        .collection('drivers')
                        .doc(widget.driverId)
                        .update({
                      "name": nameController.text,
                      "profileCompleted": true,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Saved ✅")),
                    );

                    setState(() {});
                  },
                  child: const Text("Save Profile"),
                ),

                if (completed)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Profile already completed ✅"),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}