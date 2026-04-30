import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/waafi_payment_service.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  int step = 1;

  final amountController = TextEditingController();

  String fromCompany = "Hormuud";
  String toCompany = "Somtel";

  double fee = 0;
  double total = 0;

  final List<String> companies = [
    "Hormuud",
    "Somtel",
    "Somnet",
    "Premier",
    "Somlink",
    "Amtel",
  ];

  void calculate() {
    final amount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      fee = amount * 0.02;
      total = amount + fee;
    });
  }

  Future<void> makePayment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login first")),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) { // Changed context name to avoid conflict
        return AlertDialog(
          title: const Text("Confirm Payment"),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "EVC Number (252...)",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final res = await WaafiPaymentService.makePayment(
                  phone: phoneController.text,
                  amount: amount,
                  referenceId:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  description:
                      "Exchange $fromCompany -> $toCompany",
                );

                final msg =
                    res["responseMsg"]?.toString().toLowerCase() ?? "";

                // Check if the widget is still in the tree after async call
                if (!mounted) return;

                if (msg.contains("success") ||
                    msg.contains("approved")) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Success ✅"),
                      content: Text(
                        "$fromCompany → $toCompany\n\$${amount.toStringAsFixed(2)}",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.toString())),
                  );
                }
              },
              child: const Text("Pay"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exchange Money")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: step == 1 ? buildStep1() : buildStep2(),
      ),
    );
  }

  // ================= STEP 1 =================
  Widget buildStep1() {
    return Column(
      children: [
        const Text(
          "Choose Companies",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField(
          // Fix: Using initialValue instead of value for newer Flutter versions
          initialValue: fromCompany,
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => fromCompany = v.toString()),
          decoration: const InputDecoration(labelText: "Sender Company"),
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField(
          // Fix: Using initialValue instead of value for newer Flutter versions
          initialValue: toCompany,
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => toCompany = v.toString()),
          decoration: const InputDecoration(labelText: "Receiver Company"),
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            setState(() => step = 2);
          },
          child: const Text("Next"),
        )
      ],
    );
  }

  // ================= STEP 2 =================
  Widget buildStep2() {
    return Column(
      children: [
        Text("$fromCompany → $toCompany"),

        const SizedBox(height: 20),

        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount"),
          onChanged: (_) => calculate(),
        ),

        const SizedBox(height: 10),

        Text("Fee: \$${fee.toStringAsFixed(2)}"),
        Text("Total: \$${total.toStringAsFixed(2)}"),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: makePayment,
          child: const Text("Send Money"),
        )
      ],
    );
  }
}