import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final auth =
      FirebaseAuth.instance;

  static final firestore =
      FirebaseFirestore.instance;

  Future<User?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final credential =
        await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user =
        credential.user;

    if (user != null) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'email': email,
        'role': role,
      }, SetOptions(merge: true));
    }

    return user;
  }

  User? currentUser() {
    return auth.currentUser;
  }
}