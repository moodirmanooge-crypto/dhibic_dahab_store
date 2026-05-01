import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/waafi_payment_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String deliveryType = "delivery";

  Future<void> updateQuantity(
      String userId,
      String productId,
      int quantity) async {
    if (quantity <= 0) {
      await removeItem(userId, productId);
      return;
    }

    await FirebaseFirestore.instance
        .collection("cart")
        .doc(userId)
        .collection("items")
        .doc(productId)
        .update({"quantity": quantity});
  }

  Future<void> removeItem(
      String userId,
      String productId) async {
    await FirebaseFirestore.instance
        .collection("cart")
        .doc(userId)
        .collection("items")
        .doc(productId)
        .delete();
  }

  // ✅ SUCCESS POPUP (UPDATED)
  Future<void> _showSuccessDialog({
    required String senderPhone,
    required String receiverPhone,
    required String orderId,
    required double total,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    size: 80, color: Colors.green),
                const SizedBox(height: 10),
                const Text(
                  "Payment Successful",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Sender: $senderPhone"),
                Text("Receiver: $receiverPhone"),
                const SizedBox(height: 5),
                Text("Order ID: $orderId",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  "Amount: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "MACAAMIIL FADLAN\nWARQADAAN RASIIDKA\nSCREENSHOT KAQAADO\nMAHADSANID 🙏",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkout(
    BuildContext context,
    String senderPhone,
    String receiverPhone,
    String address,
    double total,
  ) async {
    try {
      if (senderPhone.isEmpty ||
          receiverPhone.isEmpty ||
          address.isEmpty) {
        throw "Fill all fields";
      }

      String userId =
          FirebaseAuth.instance.currentUser!.uid;

      var cartSnap = await FirebaseFirestore.instance
          .collection("cart")
          .doc(userId)
          .collection("items")
          .get();

      if (cartSnap.docs.isEmpty) {
        throw "Cart is empty";
      }

      // ✅ 4 digit order ID
      String orderId =
          (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
              .toString();

      final payment =
          await WaafiPaymentService.makePayment(
        phone: senderPhone,
        amount: total,
        referenceId: orderId,
        description: "Cart Checkout",
      );

      final response =
          payment["responseMsg"]
                  ?.toString()
                  .toLowerCase() ??
              "";

      if (response.contains("success") ||
          response.contains("approved") ||
          response.contains("accepted") ||
          response.contains("pending")) {

        for (var item in cartSnap.docs) {
          final data = item.data();

          // ✅ IMPORTANT FIX (merchant total)
          double itemTotal =
              (data["price"] ?? 0) *
                  (data["quantity"] ?? 1);

          await FirebaseFirestore.instance
              .collection("orders")
              .doc(orderId + item.id)
              .set({
            "orderId": orderId,
            "customerId": userId,

            "senderPhone": senderPhone,
            "receiverPhone": receiverPhone,
            "address": address,
            "deliveryType": deliveryType,

            // ✅ MERCHANT DATA
            "merchantId": data["merchantId"] ?? "",
            "merchantName": data["merchantName"] ?? "",
            "merchantPhone": data["merchantPhone"] ?? "",
            "image": data["image"] ?? "",

            // ✅ PRODUCT
            "productName": data["name"],
            "price": data["price"],
            "quantity": data["quantity"],

            // 🔥 FIXED (NOT global total)
            "total": itemTotal,

            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
          });

          await item.reference.delete();
        }

        if (!context.mounted) return;

        await _showSuccessDialog(
          senderPhone: senderPhone,
          receiverPhone: receiverPhone,
          orderId: orderId,
          total: total,
        );

        return;
      }

      throw "Payment failed";
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6A9),
      appBar: AppBar(title: const Text("Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .doc(userId)
            .collection("items")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          var items = snapshot.data!.docs;

          double subtotal = 0;
          for (var item in items) {
            subtotal +=
                (item["price"] ?? 0) *
                    (item["quantity"] ?? 1);
          }

          double delivery =
              deliveryType == "pickup" ? 0 : 1;

          double total = subtotal + delivery;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];

                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black12)
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: Image.network(
                              item["image"],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(item["name"],
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold)),
                                Text("\$${item["price"]}",
                                    style: const TextStyle(
                                        color: Colors.green)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  updateQuantity(
                                    userId,
                                    item.id,
                                    item["quantity"] - 1,
                                  );
                                },
                              ),
                              Text(item["quantity"].toString()),
                              IconButton(
                                icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  updateQuantity(
                                    userId,
                                    item.id,
                                    item["quantity"] + 1,
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              RadioListTile<String>(
                title: const Text("Self Pickup"),
                value: "pickup",
                groupValue: deliveryType,
                onChanged: (v) =>
                    setState(() => deliveryType = v!),
              ),
              RadioListTile<String>(
                title: const Text("Delivery (+\$1)"),
                value: "delivery",
                groupValue: deliveryType,
                onChanged: (v) =>
                    setState(() => deliveryType = v!),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Subtotal: \$${subtotal.toStringAsFixed(2)}"),
                    Text("Delivery: \$${delivery.toStringAsFixed(2)}"),
                    Text(
                      "Total: \$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        final sender =
                            TextEditingController();
                        final receiver =
                            TextEditingController();
                        final address =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Payment"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: sender,
                                  decoration:
                                      const InputDecoration(labelText: "Your Phone"),
                                ),
                                TextField(
                                  controller: receiver,
                                  decoration:
                                      const InputDecoration(labelText: "Receiver Phone"),
                                ),
                                TextField(
                                  controller: address,
                                  decoration:
                                      const InputDecoration(labelText: "Address"),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  checkout(
                                    context,
                                    sender.text.trim(),
                                    receiver.text.trim(),
                                    address.text.trim(),
                                    total,
                                  );
                                },
                                child: const Text("Pay"),
                              )
                            ],
                          ),
                        );
                      },
                      child: const Text("Checkout"),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}