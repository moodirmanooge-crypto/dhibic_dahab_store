import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../service/waafi_payment_service.dart';
import '../service/notification_service.dart';

import 'exchange/hormuud/hormuud_screen.dart';
import 'exchange/somnet/somnet_screen.dart';
import 'exchange/somtel/somtel_screen.dart';
import 'exchange/somlink/somlink_screen.dart';
import 'exchange/amtel/amtel_screen.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  static const Color primary = Color(0xFF060B4F);

  int selectedTab = 0;

  final amountController = TextEditingController();
  final senderController = TextEditingController();
  final receiverController = TextEditingController();

  String fromCompany = "Premier";
  String toCompany = "Hormuud";

  double netAmount = 0.0;
  double fee = 0.0;
  bool isLoading = false;

  final List<String> companies = [
    "Hormuud",
    "Somtel",
    "Somnet",
    "Premier",
    "EVC",
    "eDahab",
    "Jeeb",
  ];

  Future<Map<String, dynamic>> payWithPremier({
    required String phone,
    required double amount,
  }) async {
    final url = Uri.parse(
      "https://us-central1-dhibic-dahab-online-store.cloudfunctions.net/paymeny-payWithPremier",
    );

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone, // ✅ sax
          "amount": amount,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  void calculateNet() {
    final amount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      fee = amount * 0.02;
      netAmount = amount - fee;
    });
  }

  bool validateNumber(String company, String number) {
    switch (company) {
      case "Premier":
        return number.length == 12 && number.startsWith("25261");

      case "Hormuud":
      case "EVC":
      case "eDahab":
        return number.length == 9 &&
            (number.startsWith("61") || number.startsWith("77"));

      case "Somtel":
      case "Jeeb":
        return number.length == 9 && number.startsWith("62");

      case "Somnet":
        return number.length == 9 && number.startsWith("68");

      default:
        return false;
    }
  }

  Future<void> submitExchange() async {
    if (!validateNumber(fromCompany, senderController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$fromCompany number waa qalad")),
      );
      return;
    }

    if (!validateNumber(toCompany, receiverController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$toCompany number waa qalad")),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fadlan geli lacag sax ah")),
      );
      return;
    }

    setState(() => isLoading = true);

    Map<String, dynamic> response;

    if (fromCompany == "Premier") {
      response = await payWithPremier(
        phone: senderController.text,
        amount: amount,
      );
    } else {
      response = await WaafiPaymentService.makePayment(
        phone: senderController.text,
        amount: amount,
        referenceId: DateTime.now().millisecondsSinceEpoch.toString(),
        description: "Exchange $fromCompany to $toCompany",
      );
    }

    setState(() => isLoading = false);

    if (response["success"] == true) {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection("exchange_orders")
          .doc(orderId)
          .set({
        "customerEmail":
            FirebaseAuth.instance.currentUser?.email ?? "No email",
        "senderNumber": senderController.text,
        "receiverNumber": receiverController.text,
        "fromCompany": fromCompany,
        "toCompany": toCompany,
        "amount": amount,
        "finalAmount": netAmount,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await NotificationService.showNotification(
        title: "New Exchange Order",
        body:
            "${FirebaseAuth.instance.currentUser?.email ?? 'User'} sent \$${amount.toStringAsFixed(2)}",
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExchangeSuccessScreen(
            senderPhone: senderController.text,
            receiverPhone: receiverController.text,
            fromCompany: fromCompany,
            toCompany: toCompany,
            originalAmount: amount,
            finalAmount: netAmount,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["error"] ?? "Approve your payment"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dhibic Dahab Exchange"),
        backgroundColor: primary,
      ),
      body: Center(child: Text("READY")),
    );
  }
}

class ExchangeSuccessScreen extends StatelessWidget {
  final String senderPhone;
  final String receiverPhone;
  final String fromCompany;
  final String toCompany;
  final double originalAmount;
  final double finalAmount;

  const ExchangeSuccessScreen({
    super.key,
    required this.senderPhone,
    required this.receiverPhone,
    required this.fromCompany,
    required this.toCompany,
    required this.originalAmount,
    required this.finalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Payment Successful!\n\$${finalAmount.toStringAsFixed(2)}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}