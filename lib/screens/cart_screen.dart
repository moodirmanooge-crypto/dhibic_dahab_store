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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
          child: Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Payment Successful",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text("Phone: $phone"),
                const SizedBox(height: 8),
                Text(
                  "Order ID: $orderId",
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Mahadsanid adeegashadaada Dhibic Dahab Online Store\nFadlan form kaan Screenshot ka qaado",
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    child:
                        const Text("OK"),
                  ),
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
      String phone) async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid;

      final userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

      final userData =
          userDoc.data() ?? {};

      final customerName =
          userData["name"] ??
              userData["fullName"] ??
              userData["username"] ??
              "Unknown Customer";

      final customerPhoneFromDb =
          userData["phone"] ?? phone;

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
          deliveryType == "pickup"
              ? 0
              : 1.0;

      double total =
          subtotal + deliveryFee;

      String orderId =
          (1000 +
                  (DateTime.now()
                          .millisecondsSinceEpoch %
                      9000))
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
          response.contains("approved") ||
          response.contains(
              "rcs_success")) {
        for (var item in cartSnap.docs) {
          final data =
              item.data()
                  as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection("orders")
              .doc(orderId + item.id)
              .set({
            "id": orderId + item.id,
            "orderId": orderId,
            "merchantId":
                data["merchantId"] ?? "",
            "merchantName":
                data["merchantName"] ??
                    "Unknown Seller",
            "merchantPhone":
                data["merchantPhone"] ??
                    "",
            "customerId": userId,
            "customerName":
                customerName,
            "customerPhone":
                customerPhoneFromDb,
            "productName":
                data["name"] ?? "",
            "image":
                data["image"] ?? "",
            "price":
                data["price"] ?? 0,
            "quantity":
                data["quantity"] ?? 1,
            "deliveryType":
                deliveryType,
            "deliveryFee":
                deliveryFee,
            "subtotal": subtotal,
            "total": total,
            "paymentResponse":
                payment,
            "paymentStatus":
                "paid",
            "status": "pending",
            "createdAt":
                FieldValue
                    .serverTimestamp(),
            "date": DateTime.now()
                .toString(),
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

      if (response.contains(
              "insufficient") ||
          response.contains(
              "balance")) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "❌ Fadlan marka hore lacag kushubo"),
            backgroundColor:
                Colors.red,
          ),
        );
        return;
      }

      throw "Payment failed";
    } catch (e) {
      if (!mounted) return;

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
              deliveryType ==
                      "pickup"
                  ? 0
                  : 1;

          double total =
              subtotal + delivery;

          return Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.all(15),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                          20),
                  image:
                      const DecorationImage(
                    image: AssetImage(
                      "assets/images/delivery_bike.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Colors.black12,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder:
                      (context, index) {
                    var item = items[index];

                    return Container(
                      margin:
                          const EdgeInsets
                              .all(8),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius:
                                8,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading:
                            ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                          child:
                              Image.network(
                            item["image"],
                            width: 60,
                            height: 60,
                            fit: BoxFit
                                .cover,
                          ),
                        ),
                        title: Text(
                          item["name"],
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        subtitle: Text(
                          "\$${item["price"]}",
                          style:
                              const TextStyle(
                            color: Colors
                                .green,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            IconButton(
                              onPressed:
                                  () {
                                updateQuantity(
                                  userId,
                                  item.id,
                                  item["quantity"] -
                                      1,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .remove_circle,
                                color: Colors
                                    .red,
                              ),
                            ),
                            Text(item[
                                    "quantity"]
                                .toString()),
                            IconButton(
                              onPressed:
                                  () {
                                updateQuantity(
                                  userId,
                                  item.id,
                                  item["quantity"] +
                                      1,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .add_circle,
                                color: Colors
                                    .green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              RadioListTile(
                title: const Text(
                    "Self Pickup"),
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
                    Text(
                        "Subtotal: \$$subtotal"),
                    Text(
                        "Delivery: \$$delivery"),
                    Text(
                      "Total: \$$total",
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                        height: 15),
                    ElevatedButton(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFD4AF37),
                      ),
                      onPressed: () {
                        final phoneController =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title:
                                  const Text(
                                      "Payment"),
                              content:
                                  TextField(
                                controller:
                                    phoneController,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      "Phone",
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed:
                                      () {
                                    Navigator.pop(
                                        context);
                                    checkout(
                                      context,
                                      phoneController
                                          .text,
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