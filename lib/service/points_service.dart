import 'package:cloud_firestore/cloud_firestore.dart';

class PointsService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<void> addPoints(
    String customerId,
    double orderAmount,
  ) async {
    double earnedPoints =
        orderAmount * 0.01;

    final userRef =
        _db.collection("users").doc(customerId);

    final userSnap =
        await userRef.get();

    final data =
        userSnap.data() ?? {};

    final oldPoints =
        (data["points"] ?? 0)
            .toDouble();

    await userRef.set({
      "points":
          oldPoints + earnedPoints,
    }, SetOptions(merge: true));
  }
}