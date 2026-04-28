import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/cart_provider.dart';
import '../service/notification_service.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<void> _showPaymentSuccessDialog({
    required BuildContext context,
    required String email,
    required String orderId,
    required double total,
    required VoidCallback onOk,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Email: $email",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Order ID: $orderId",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount Paid: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mahadsanid adeegashadaada Dhibic Dahab Online Store.\nFadlan screenshot ka qaado.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onOk();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    const double deliveryFee = 5.0;

    final double grandTotal =
        cart.totalPrice + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Products total: \$${cart.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Delivery: \$5.00",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Grand Total: \$${grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD4AF37),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                onPressed: () async {
                  final prefs =
                      await SharedPreferences
                          .getInstance();

                  final email =
                      prefs.getString("email") ??
                          "customer@email.com";

                  final orderId =
                      Random()
                          .nextInt(999999)
                          .toString();

                  await _showPaymentSuccessDialog(
                    context: context,
                    email: email,
                    orderId: orderId,
                    total: grandTotal,
                    onOk: () async {
                      await FirebaseFirestore
                          .instance
                          .collection("orders")
                          .doc(orderId)
                          .set({
                        "orderId": orderId,
                        "customerEmail": email,
                        "merchantId":
                            "merchant_001",
                        "driverId":
                            "driver_001",
                        "status": "pending",
                        "total": grandTotal,
                        "createdAt":
                            Timestamp.now(),
                      });

                      /// 🔥 MERCHANT POPUP NOTIFICATION
                      NotificationService
                          .showNotification(
                        title: "New Order",
                        body:
                            "Please approve your order",
                      );

                      /// 🔥 CLEAR CART
                      cart.clearCart();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentScreen(
                            amount:
                                grandTotal,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}