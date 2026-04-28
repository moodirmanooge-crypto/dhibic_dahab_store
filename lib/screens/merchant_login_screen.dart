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
        SnackBar(content: Text("Invalid merchant code")),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Merchant Login")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(

          children: [

            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: "Enter Merchant Code",
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: loginMerchant,
              child: Text("Login"),
            )

          ],
        ),
      ),
    );
  }
}