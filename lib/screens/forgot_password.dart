import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() =>
          _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<
        ForgotPasswordScreen> {
  final TextEditingController
      emailController =
      TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {
    final email =
        emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Enter your email"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset email sent ✅",
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg =
          "Reset failed ❌";

      if (e.code ==
          "user-not-found") {
        msg =
            "Email not found ❌";
      } else if (e.code ==
          "invalid-email") {
        msg =
            "Invalid email ❌";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(msg),
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
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: const Text(
          "Reset Password",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
                20),
        child: Column(
          children: [
            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Enter your email",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(
                height: 20),
            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : resetPassword,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xFFD4AF37),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Send Reset Link",
                        style: TextStyle(
                          color: Colors
                              .white,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}