import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawScreen extends StatefulWidget {

  final String merchantId;

  const WithdrawScreen({super.key, required this.merchantId});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {

  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  bool loading = false;

  Future requestWithdraw() async {

    setState(() {
      loading = true;
    });

    double amount = double.parse(amountController.text);

    await FirebaseFirestore.instance.collection("withdraw_requests").add({

      "merchantId": widget.merchantId,
      "phone": phoneController.text,
      "amount": amount,
      "status": "pending",
      "createdAt": Timestamp.now()

    });

    // ✅ Hubinta 'mounted' si looga saaro error-ka Context-ka async ka dib
    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Withdraw request sent")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Withdraw Money"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Hormuud Number",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading ? null : requestWithdraw,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Request Withdraw"),

              ),
            )

          ],

        ),

      ),

    );

  }

}