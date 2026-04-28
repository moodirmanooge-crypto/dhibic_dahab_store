import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<bool> exchangeMoney(
    String userId,
    String receiverPhone,
  ) async {
    final userRef =
        _db.collection("users").doc(userId);

    final userSnap =
        await userRef.get();

    final points =
        (userSnap.data()?["points"] ?? 0)
            .toDouble();

    if (points < 100) {
      return false;
    }

    await userRef.update({
      "points": points - 100,
    });

    await _db.collection("exchange_requests").add({
      "userId": userId,
      "receiverPhone":
          receiverPhone,
      "amount": 1,
      "status": "pending",
      "createdAt":
          FieldValue.serverTimestamp(),
    });

    return true;
  }

  Future<bool> exchangeData(
    String userId,
    String phone,
  ) async {
    final userRef =
        _db.collection("users").doc(userId);

    final userSnap =
        await userRef.get();

    final points =
        (userSnap.data()?["points"] ?? 0)
            .toDouble();

    if (points < 100) {
      return false;
    }

    await userRef.update({
      "points": points - 100,
    });

    await _db.collection("data_requests").add({
      "userId": userId,
      "phone": phone,
      "package":
          "Unlimited 24 Hours",
      "status": "pending",
      "createdAt":
          FieldValue.serverTimestamp(),
    });

    return true;
  }
}