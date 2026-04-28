import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/waafi_payment_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
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
        .update({
      "quantity": quantity,
    });
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

  Future<void> _showSuccessDialog({
    required String phone,
    required String orderId,
    required double total,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Payment Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Phone: $phone"),
              Text("Order ID: $orderId"),
              Text("Amount: \$${total.toStringAsFixed(2)}"),
              const SizedBox(height: 10),
              const Text(
                "Mahadsanid 🙏 Screenshot qaado",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  Future<void> checkout(
    BuildContext context,
    String phone,
    String receiverPhone,
    String address,
  ) async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid;

      var cartSnap = await FirebaseFirestore
          .instance
          .collection("cart")
          .doc(userId)
          .collection("items")
          .get();

      if (cartSnap.docs.isEmpty) {
        throw "Cart is empty";
      }

      double subtotal = 0;

      for (var item in cartSnap.docs) {
        subtotal +=
            (item["price"] ?? 0) *
                (item["quantity"] ?? 1);
      }

      double deliveryFee =
          deliveryType == "pickup" ? 0 : 1;

      double total =
          subtotal + deliveryFee;

      String orderId =
          DateTime.now()
              .millisecondsSinceEpoch
              .toString();

      final payment =
          await WaafiPaymentService.makePayment(
        phone: phone,
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
          response.contains("approved")) {
        for (var item in cartSnap.docs) {
          final data =
              item.data()
                  as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection("orders")
              .doc(orderId + item.id)
              .set({
            "orderId": orderId,
            "customerId": userId,
            "phone": phone,
            "receiverPhone": receiverPhone, // 🔥 NEW
            "address": address, // 🔥 NEW
            "productName": data["name"],
            "price": data["price"],
            "quantity": data["quantity"],
            "total": total,
            "status": "pending",
            "createdAt":
                FieldValue.serverTimestamp(),
          });

          await item.reference.delete();
        }

        if (!mounted) return;

        await _showSuccessDialog(
          phone: phone,
          orderId: orderId,
          total: total,
        );
        return;
      }

      throw "Payment failed";
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5E6A9),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: const Text("Cart"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .doc(userId)
            .collection("items")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          var items = snapshot.data!.docs;

          double subtotal = 0;

          for (var item in items) {
            subtotal +=
                (item["price"] ?? 0) *
                    (item["quantity"] ?? 1);
          }

          double delivery =
              deliveryType == "pickup"
                  ? 0
                  : 1;

          double total =
              subtotal + delivery;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder:
                      (context, index) {
                    var item = items[index];

                    return ListTile(
                      title: Text(item["name"]),
                      subtitle:
                          Text("\$${item["price"]}"),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              updateQuantity(
                                userId,
                                item.id,
                                item["quantity"] -
                                    1,
                              );
                            },
                            icon: const Icon(
                                Icons.remove),
                          ),
                          Text(item["quantity"]
                              .toString()),
                          IconButton(
                            onPressed: () {
                              updateQuantity(
                                userId,
                                item.id,
                                item["quantity"] +
                                    1,
                              );
                            },
                            icon: const Icon(
                                Icons.add),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              RadioListTile(
                title:
                    const Text("Self Pickup"),
                value: "pickup",
                groupValue:
                    deliveryType,
                onChanged: (v) {
                  setState(() {
                    deliveryType = v!;
                  });
                },
              ),

              RadioListTile(
                title:
                    const Text("Delivery"),
                value: "delivery",
                groupValue:
                    deliveryType,
                onChanged: (v) {
                  setState(() {
                    deliveryType = v!;
                  });
                },
              ),

              Padding(
                padding:
                    const EdgeInsets.all(
                        16),
                child: Column(
                  children: [
                    Text("Total: \$$total"),
                    const SizedBox(
                        height: 10),

                    ElevatedButton(
                      onPressed: () {
                        final phone =
                            TextEditingController();
                        final receiver =
                            TextEditingController();
                        final address =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title:
                                  const Text(
                                      "Payment"),
                              content: Column(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,
                                children: [
                                  TextField(
                                    controller:
                                        phone,
                                    decoration:
                                        const InputDecoration(
                                      labelText:
                                          "Your Phone",
                                    ),
                                  ),
                                  TextField(
                                    controller:
                                        receiver,
                                    decoration:
                                        const InputDecoration(
                                      labelText:
                                          "Receiver Phone",
                                    ),
                                  ),
                                  TextField(
                                    controller:
                                        address,
                                    decoration:
                                        const InputDecoration(
                                      labelText:
                                          "Address",
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context);
                                    checkout(
                                      context,
                                      phone.text,
                                      receiver.text,
                                      address.text,
                                    );
                                  },
                                  child:
                                      const Text(
                                          "Pay"),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child:
                          const Text(
                              "Checkout"),
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