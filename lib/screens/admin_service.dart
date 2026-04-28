import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {

  static Future<bool> isAdmin() async {

    var user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    var snapshot = await FirebaseFirestore.instance
        .collection("admins")
        .where("email", isEqualTo: user.email)
        .get();

    return snapshot.docs.isNotEmpty;

  }

}