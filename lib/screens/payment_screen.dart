import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../service/waafi_payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Book book;

  const PaymentScreen({
    super.key,
    required this.book,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController pinController =
      TextEditingController();

  bool isLoading = false;

  Future<void> _showPaymentSuccessDialog({
    required String phone,
    required String referenceId,
    required double amount,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
                const SizedBox(height: 16),
                Text(
                  "Phone: $phone",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ref ID: $referenceId",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount Paid: \$${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mahadsanid adeegashadaada Dhibic Dahab Online Store.\nFadlan Screenshot ka qaado.",
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
                          dialogContext); // close dialog
                      Navigator.pop(
                          context,
                          true); // return success
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 18,
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

  Future<void> payBook() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw "User not logged in";
      }

      final phone =
          phoneController.text.trim();

      final pin =
          pinController.text.trim();

      if (phone.isEmpty || pin.isEmpty) {
        throw "Fadlan geli phone iyo PIN";
      }

      setState(() {
        isLoading = true;
      });

      final amount =
          double.tryParse(
                widget.book.price.toString(),
              ) ??
              0;

      final referenceId =
          "book_${DateTime.now().millisecondsSinceEpoch}";

      final result =
          await WaafiPaymentService.makePayment(
        phone: phone,
        amount: amount,
        referenceId:
            referenceId,
        description:
            "Book Purchase - ${widget.book.title}",
      );

      final bool success =
          result["responseMsg"] ==
                  "RCS_SUCCESS" ||
              result["responseCode"]
                      .toString() ==
                  "2001";

      if (!success) {
        throw "Payment failed";
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("purchased_books")
          .doc(widget.book.id)
          .set({
        "bookId": widget.book.id,
        "title": widget.book.title,
        "pdfUrl": widget.book.pdfUrl,
        "price": widget.book.price,
        "phone": phone,
        "paidAt": Timestamp.now(),
        "isPaid": true,
      });

      await FirebaseFirestore.instance
          .collection("notifications")
          .add({
        "title":
            "Buying Book With Customer",
        "body":
            "Customer bought a book",
        "type": "book",
        "bookId": widget.book.id,
        "bookTitle":
            widget.book.title,
        "userId": user.uid,
        "customerPhone": phone,
        "createdAt":
            FieldValue.serverTimestamp(),
        "isRead": false,
      });

      if (!mounted) return;

      await _showPaymentSuccessDialog(
        phone: phone,
        referenceId:
            referenceId,
        amount: amount,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Waafi Payment"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.book.title,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "\$${widget.book.price}",
              style:
                  const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller:
                  phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText:
                    "Phone Number",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller:
                  pinController,
              obscureText: true,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "PIN",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : payBook,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )
                    : const Text(
                        "Pay & Open Book",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}