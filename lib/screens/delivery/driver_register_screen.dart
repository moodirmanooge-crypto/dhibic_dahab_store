import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;

  Future<void> registerDriver() async {
    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection('drivers').add({
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
        "phone": phoneController.text.trim(),
        "isActive": true,
        "wallet": 0,
        "createdAt": Timestamp.now(),
      });

      // ✅ Hubinta mounted si looga saaro error-ka Context-ka
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver Registered ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),

            const SizedBox(height: 15), // ✅ const lagu daray

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 15), // ✅ const lagu daray

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 25), // ✅ const lagu daray

            ElevatedButton(
              onPressed: loading ? null : registerDriver,
              child: loading
                  ? const CircularProgressIndicator() // ✅ const lagu daray
                  : const Text("Register"), // ✅ const lagu daray
            )
          ],
        ),
      ),
    );
  }
}