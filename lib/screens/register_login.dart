import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterLogin extends StatefulWidget {
  const RegisterLogin({super.key});

  @override
  State<RegisterLogin> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<RegisterLogin> {
  final codeController = TextEditingController();
  final nameController = TextEditingController(); // NEW
  final emailController = TextEditingController();
  final merchantPhoneController = TextEditingController();

  final commissionController =
      TextEditingController(text: "10");

  final walletController =
      TextEditingController(text: "0");

  final fcmTokenController =
      TextEditingController(text: "empty");

  final categoryController =
      TextEditingController();

  final otherMerchantNameController =
      TextEditingController();

  final otherMerchantPhoneController =
      TextEditingController();

  bool loading = false;

  Future<void> registerMerchant() async {
    try {
      final code = codeController.text.trim();
      final name = nameController.text.trim();

      if (code.isEmpty) {
        throw "Merchant code required";
      }

      if (name.isEmpty) {
        throw "Merchant name required";
      }

      setState(() => loading = true);

      await FirebaseFirestore.instance
          .collection("merchant")
          .doc(code)
          .set({
        "code": code,
        "name": name, // IMPORTANT
        "email": emailController.text.trim(),
        "merchantPhone":
            merchantPhoneController.text.trim(),
        "image": "",
        "commission":
            num.tryParse(
                  commissionController.text.trim(),
                ) ??
                10,
        "wallet":
            num.tryParse(
                  walletController.text.trim(),
                ) ??
                0,
        "fcmToken":
            fcmTokenController.text.trim(),
        "category":
            categoryController.text.trim(),
        "otherMerchantName":
            otherMerchantNameController.text.trim(),
        "otherMerchantPhone":
            otherMerchantPhoneController.text.trim(),
        "salesCount": 0,
        "totalSales": 0,
        "commissionEarned": 0,
        "discountPercent": "0",
        "isDiscountActive": false,
        "approved": true,
        "createdAt":
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ Merchant registered successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    emailController.dispose();
    merchantPhoneController.dispose();
    commissionController.dispose();
    walletController.dispose();
    fcmTokenController.dispose();
    categoryController.dispose();
    otherMerchantNameController.dispose();
    otherMerchantPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Register Merchant"),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField(
              controller: codeController,
              label: "Merchant Code",
            ),
            buildField(
              controller: nameController,
              label: "Merchant Name",
            ),
            buildField(
              controller: emailController,
              label: "Email",
            ),
            buildField(
              controller: merchantPhoneController,
              label: "Merchant Phone",
            ),
            buildField(
              controller: commissionController,
              label: "Commission",
            ),
            buildField(
              controller: walletController,
              label: "Wallet",
            ),
            buildField(
              controller: fcmTokenController,
              label: "FCM Token",
            ),
            buildField(
              controller: categoryController,
              label: "Category",
            ),
            buildField(
              controller:
                  otherMerchantNameController,
              label: "Other Merchant Name",
            ),
            buildField(
              controller:
                  otherMerchantPhoneController,
              label: "Other Merchant Phone",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : registerMerchant,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD4AF37),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Register",
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