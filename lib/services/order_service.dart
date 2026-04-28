import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {

  static Future<void> placeOrder(List cartItems) async {

    String userId = FirebaseAuth.instance.currentUser!.uid;

    double total = 0;

    for (var item in cartItems) {
      total += item["price"] * item["quantity"];
    }

    double deliveryFee = 1;

    DocumentReference orderRef =
        await FirebaseFirestore.instance.collection("orders").add({

      "merchantId": cartItems.first["merchantId"],
      "userId": userId,
      "total": total,
      "deliveryFee": deliveryFee,
      "status": "pending",
      "createdAt": Timestamp.now()

    });

    for (var item in cartItems) {

      await orderRef.collection("items").add({

        "name": item["name"],
        "price": item["price"],
        "quantity": item["quantity"],
        "image": item["image"]

      });

    }

  }
}