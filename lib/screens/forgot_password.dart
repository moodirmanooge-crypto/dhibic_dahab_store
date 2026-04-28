import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final TextEditingController emailController =
      TextEditingController();

  void resetPassword() async {

    String email = emailController.text.trim();

    if(email.isEmpty) return;

    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Password reset email sent"),
      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reset Password"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children:[

            TextField(

              controller: emailController,

              decoration: const InputDecoration(
                labelText:"Enter your email",
              ),

            ),

            const SizedBox(height:20),

            ElevatedButton(

              onPressed: resetPassword,

              child: const Text("Send Reset Link"),

            )

          ],

        ),

      ),

    );

  }

}