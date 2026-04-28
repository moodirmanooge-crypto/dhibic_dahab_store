import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;

  /// ================= EMAIL REGISTER =================
  Future<void> registerUser() async {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Fill all fields ❌"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user =
          userCredential.user;

      if (user == null) {
        throw Exception(
            "Account creation failed");
      }

      /// SEND EMAIL VERIFICATION
      await user.sendEmailVerification();

      /// SAVE USER TO FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "email": email,
        "role": "customer",
        "provider": "email",
        "isVerified": false,
        "createdAt":
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Verification email sent 📩 Check your inbox",
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message =
          "Registration failed ❌";

      if (e.code ==
          'email-already-in-use') {
        message =
            "Email already exists";
      } else if (e.code ==
          'invalid-email') {
        message =
            "Invalid email address";
      } else if (e.code ==
          'weak-password') {
        message =
            "Password too weak";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ================= GOOGLE REGISTER =================
  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn();

      final GoogleSignInAccount?
          googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication
          googleAuth =
          await googleUser
              .authentication;

      final credential =
          GoogleAuthProvider
              .credential(
        accessToken:
            googleAuth.accessToken,
        idToken:
            googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance
              .signInWithCredential(
        credential,
      );

      final user =
          userCredential.user!;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "email": user.email,
        "name":
            user.displayName,
        "photo":
            user.photoURL,
        "role": "customer",
        "provider": "google",
        "isVerified": true,
        "createdAt":
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("❌ $e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Register"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
                height: 20),

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(),
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
                border:
                    OutlineInputBorder(),
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
                        : registerUser,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Create with Email",
                      ),
              ),
            ),

            const SizedBox(
                height: 20),

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : signInWithGoogle,
                icon: const Icon(
                    Icons.login),
                label: const Text(
                  "Continue with Google",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}