import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_screen.dart';
import 'admin_panel.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['email']);

  Future<String> getUserRole(
      String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .get();

      if (doc.exists) {
        return doc.data()?["role"] ??
            "customer";
      }

      return "customer";
    } catch (e) {
      return "customer";
    }
  }

  Future<void> saveLoginData({
    required String email,
    required String role,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
        "isLoggedIn", true);

    await prefs.setString(
        "email", email);

    await prefs.setString(
        "role", role);
  }

  void navigateByRole(String role) {
    if (!mounted) return;

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminPanel(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainScreen(),
        ),
      );
    }
  }

  Future<void> loginUser() async {
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
              Text("Fill all fields"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user =
          credential.user;

      String role = "customer";

      if (user != null) {
        role =
            await getUserRole(
                user.uid);
      }

      await saveLoginData(
        email: email,
        role: role,
      );

      navigateByRole(role);
    } on FirebaseAuthException catch (e) {
      String msg =
          "Login failed ❌";

      if (e.code ==
              "user-not-found" ||
          e.code ==
              "invalid-credential") {
        msg = "Wrong email ❌";
      } else if (e.code ==
          "wrong-password") {
        msg =
            "Wrong password ❌";
      } else if (e.code ==
          "invalid-email") {
        msg =
            "Invalid email format ❌";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void>
      createNewAccount() async {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Enter email and password first"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user =
          credential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "email": email,
          "role": "customer",
          "createdAt":
              FieldValue.serverTimestamp(),
        });

        await saveLoginData(
          email: email,
          role: "customer",
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "Account created successfully ✅"),
          ),
        );

        navigateByRole(
            "customer");
      }
    } on FirebaseAuthException catch (e) {
      String msg =
          "Account creation failed ❌";

      if (e.code ==
          "email-already-in-use") {
        msg =
            "Email already exists ❌";
      } else if (e.code ==
          "invalid-email") {
        msg =
            "Wrong email ❌";
      } else if (e.code ==
          "weak-password") {
        msg =
            "Password too weak ❌";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void>
      loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await googleSignIn.signOut();

      final googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final googleAuth =
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
                  credential);

      final user =
          userCredential.user;

      String role = "customer";

      if (user != null) {
        role =
            await getUserRole(
                user.uid);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "email": user.email,
          "role": role,
        }, SetOptions(merge: true));
      }

      await saveLoginData(
        email:
            googleUser.email,
        role: role,
      );

      navigateByRole(role);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Google login failed ❌"),
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
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
                  20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const SizedBox(
                  height: 50),
              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 25),
              ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : loginWithGoogle,
                icon: const Icon(
                  Icons.account_circle,
                ),
                label: const Text(
                  "Continue with Google",
                ),
              ),
              const SizedBox(
                  height: 25),
              TextField(
                controller:
                    emailController,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Email",
                ),
              ),
              const SizedBox(
                  height: 20),
              TextField(
                controller:
                    passwordController,
                obscureText:
                    obscurePassword,
                decoration:
                    InputDecoration(
                  labelText:
                      "Password",
                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                  height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : loginUser,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Login",
                      ),
              ),
              const SizedBox(
                  height: 15),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : createNewAccount,
                child: const Text(
                  "Create New Account",
                ),
              ),
              const SizedBox(
                  height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}