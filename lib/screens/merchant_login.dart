import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'merchant_dashboard.dart';

class MerchantLogin extends StatefulWidget {
  const MerchantLogin({super.key});

  @override
  State<MerchantLogin> createState() =>
      _MerchantLoginState();
}

class _MerchantLoginState
    extends State<MerchantLogin> {
  final codeController =
      TextEditingController();

  bool isLoading = false;

  Future<void> loginMerchant() async {
    String merchantId =
        codeController.text.trim();

    if (merchantId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Fadlan geli Merchant Code"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final doc =
          await FirebaseFirestore
              .instance
              .collection("merchant")
              .doc(merchantId)
              .get();

      if (!doc.exists) {
        throw "Merchant code not found";
      }

      final data =
          doc.data()!;

      final merchantName =
          data["name"] ?? "";

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MerchantDashboard(
            merchantId:
                merchantId,
            merchantName:
                merchantName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
          backgroundColor:
              Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: const Text(
          "Merchant Login",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
                height: 30),

            Container(
              padding:
                  const EdgeInsets
                      .all(20),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                            20),
                boxShadow: const [ // ✅ FIXED: Added const here
                  BoxShadow(
                    color: Colors
                        .black12,
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller:
                        codeController,
                    decoration:
                        InputDecoration(
                      labelText:
                          "Merchant Code",
                      hintText:
                          "Enter code",
                      filled: true,
                      fillColor:
                          const Color(
                              0xFFFFF8E1),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    width: double
                        .infinity,
                    child:
                        ElevatedButton(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFD4AF37),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 16,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : loginMerchant,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors
                                  .white,
                            )
                          : const Text(
                              "Login",
                              style:
                                  TextStyle(
                                fontSize:
                                    18,
                                color: Colors
                                    .white,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}