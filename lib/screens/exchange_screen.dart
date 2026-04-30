import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/waafi_payment_service.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  int step = 0; // 0 = register, 1 = exchange

  final senderNumberController = TextEditingController();
  final receiverNumberController = TextEditingController();
  final amountController = TextEditingController();

  String fromCompany = "Hormuud";
  String toCompany = "Somtel";

  double fee = 0;
  double total = 0;

  Map<String, dynamic>? userData;

  final companies = [
    "Hormuud",
    "Somtel",
    "Somnet",
    "Premier",
    "Somlink",
    "Amtel",
  ];

  @override
  void initState() {
    super.initState();
    checkUserData();
  }

  // 🔥 CHECK haddii user hore u diiwaangashan yahay
  Future<void> checkUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("exchange_users")
        .doc(uid)
        .get();

    if (doc.exists) {
      userData = doc.data();
      setState(() => step = 1);
    } else {
      setState(() => step = 0);
    }
  }

  // 🔥 SAVE USER DATA
  Future<void> saveUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("exchange_users")
        .doc(uid)
        .set({
      "senderNumber": senderNumberController.text,
      "receiverNumber": receiverNumberController.text,
      "fromCompany": fromCompany,
      "toCompany": toCompany,
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      userData = {
        "senderNumber": senderNumberController.text,
        "receiverNumber": receiverNumberController.text,
        "fromCompany": fromCompany,
        "toCompany": toCompany,
      };
      step = 1;
    });
  }

  void calculate() {
    final amount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      fee = amount * 0.02;
      total = amount + fee;
    });
  }

  // 🔥 PAYMENT + ORDER SAVE
  Future<void> makePayment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final amount = double.tryParse(amountController.text) ?? 0;

    final senderNumber = userData!["senderNumber"];
    final receiverNumber = userData!["receiverNumber"];

    final res = await WaafiPaymentService.makePayment(
      phone: senderNumber,
      amount: amount,
      referenceId: DateTime.now().millisecondsSinceEpoch.toString(),
      description: "Exchange $fromCompany -> $toCompany",
    );

    final msg =
        res["responseMsg"]?.toString().toLowerCase() ?? "";

    if (msg.contains("success") || msg.contains("approved")) {
      // 🔥 SAVE ORDER
      await FirebaseFirestore.instance
          .collection("exchange_orders")
          .add({
        "userId": uid,
        "senderNumber": senderNumber,
        "receiverNumber": receiverNumber,
        "fromCompany": fromCompany,
        "toCompany": toCompany,
        "amount": amount,
        "fee": fee,
        "total": total,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success ✅"),
          content: Text(
              "$fromCompany → $toCompany\n\$${amount.toStringAsFixed(2)}"),
        ),
      );
    } else {
      // Waxaan ku darnay !mounted check halkan si error-ka looga fogaado
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exchange Money")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: step == 0 ? buildRegister() : buildExchange(),
      ),
    );
  }

  // ================= REGISTER =================
  Widget buildRegister() {
    return Column(
      children: [
        const Text(
          "Register First Time",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        TextField(
          controller: senderNumberController,
          decoration: const InputDecoration(labelText: "Sender Number"),
        ),

        TextField(
          controller: receiverNumberController,
          decoration: const InputDecoration(labelText: "Receiver Number"),
        ),

        DropdownButtonFormField(
          // 'value' waxaan u bedelay 'initialValue'
          initialValue: fromCompany,
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => fromCompany = v.toString()),
        ),

        DropdownButtonFormField(
          // 'value' waxaan u bedelay 'initialValue'
          initialValue: toCompany,
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => toCompany = v.toString()),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: saveUserData,
          child: const Text("Save & Continue"),
        )
      ],
    );
  }

  // ================= EXCHANGE =================
  Widget buildExchange() {
    return Column(
      children: [
        if (userData != null)
          Text(
            "${userData!["fromCompany"]} → ${userData!["toCompany"]}",
          ),

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