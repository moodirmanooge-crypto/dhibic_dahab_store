import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver_home_screen.dart';
import '../../service/notification_service.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() =>
      _DriverLoginScreenState();
}

class _DriverLoginScreenState
    extends State<DriverLoginScreen> {
  final TextEditingController
      usernameController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> loginDriver() async {
    try {
      setState(() {
        isLoading = true;
      });

      final query =
          await FirebaseFirestore
              .instance
              .collection(
                  'drivers')
              .where(
                'username',
                isEqualTo:
                    usernameController
                        .text
                        .trim(),
              )
              .where(
                'password',
                isEqualTo:
                    passwordController
                        .text
                        .trim(),
              )
              .get();

      if (query.docs.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "Login Failed ❌"),
          ),
        );

        return;
      }

      final driver =
          query.docs.first;

      final data = driver.data();

      if (data['isActive'] !=
          true) {
        if (!mounted) return;

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "Driver not active"),
          ),
        );

        return;
      }

      /// INIT NOTIFICATIONS
      await NotificationService
          .init();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DriverHomeScreen(
            driverId:
                driver.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
              "Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController
        .dispose();
    passwordController
        .dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Driver Login"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
                20),
        child: Column(
          children: [
            TextField(
              controller:
                  usernameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Username",
              ),
            ),
            const SizedBox(
                height: 20),
            TextField(
              controller:
                  passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Password",
              ),
            ),
            const SizedBox(
                height: 30),
            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : loginDriver,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Login",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}