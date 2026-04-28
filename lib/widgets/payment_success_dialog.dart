import 'package:flutter/material.dart';

Future<void> showPaymentSuccessDialog({
  required BuildContext context,
  required String email,
  required String orderId,
  required double total,
  required VoidCallback onOk,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(25),
        ),
        child: Container(
          padding:
              const EdgeInsets.all(24),
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
              const SizedBox(height: 16),

              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Email: $email",
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Order ID: $orderId",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Amount Paid: \$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Mahadsanid adeegashadaada Dhibic Dahab Online Store.\nFadlan form kaan Screenshot ka qaado.",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                        context);
                    onOk();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          Colors.white,
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