import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'merchant_dashboard.dart';

class MerchantLoginScreen extends StatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  State<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends State<MerchantLoginScreen> {

  final TextEditingController codeController = TextEditingController();

  void loginMerchant() async {

    String code = codeController.text.trim();

    var snapshot = await FirebaseFirestore.instance
        .collection("merchant")
        .where("code", isEqualTo: code)
        .get();

    // ✅ Hubinta 'mounted' si looga saaro error-ka Context-ka async ka dib
    if (!mounted) return;

    if (snapshot.docs.isNotEmpty) {

      var merchant = snapshot.docs.first;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MerchantDashboard(
            merchantId: merchant.id,
            merchantName: merchant["name"],
          ),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid merchant code")), // ✅ const lagu daray
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Merchant Login")), // ✅ const lagu daray

      body: Padding(
        padding: const EdgeInsets.all(20), // ✅ const lagu daray
        child: Column(

          children: [

            TextField(
              controller: codeController,
              decoration: const InputDecoration( // ✅ const lagu daray
                labelText: "Enter Merchant Code",
              ),
            ),

            const SizedBox(height: 20), // ✅ const lagu daray

            ElevatedButton(
              onPressed: loginMerchant,
              child: const Text("Login"), // ✅ const lagu daray
            )

          ],
        ),
      ),
    );
  }
}