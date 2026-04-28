import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class DriverWalletScreen extends StatefulWidget {
  final String driverId;

  const DriverWalletScreen({
    super.key,
    required this.driverId,
  });

  @override
  State<DriverWalletScreen> createState() =>
      _DriverWalletScreenState();
}

class _DriverWalletScreenState
    extends State<DriverWalletScreen> {
  final amountController =
      TextEditingController();

  final numberController =
      TextEditingController();

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://dhibic-dahab-online-store-default-rtdb.europe-west1.firebasedatabase.app/",
  ).ref();

  void showWithdrawForm(
      double balance,
      String registeredNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Withdraw"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Gali amount",
              ),
            ),
            TextField(
              controller: numberController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText: "Phone number",
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () =>
                withdrawMoney(
              balance,
              registeredNumber,
            ),
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );
  }

  Future<void> withdrawMoney(
    double balance,
    String registeredNumber,
  ) async {
    final amount = double.tryParse(
            amountController.text) ??
        0;

    final phone =
        numberController.text.trim();

    if (balance <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Your account balance will be credited to you.",
          ),
        ),
      );
      return;
    }

    if (phone != registeredNumber) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "please approve your number",
          ),
        ),
      );
      return;
    }

    if (amount > balance) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Insufficient balance"),
        ),
      );
      return;
    }

    await db
        .child("driver_wallet")
        .child(widget.driverId)
        .child("balance")
        .set(balance - amount);

    await db
        .child("withdraw_requests")
        .push()
        .set({
      "driverId": widget.driverId,
      "amount": amount,
      "phone": phone,
      "date": DateTime.now()
          .toIso8601String(),
      "status": "pending",
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
            "✅ Withdraw request sent: \$$amount"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: db
          .child("driver_wallet")
          .child(widget.driverId)
          .onValue,
      builder: (context, snapshot) {
        double balance = 0;
        double commission = 0;
        String phone = "";

        if (snapshot.hasData &&
            snapshot.data!.snapshot.value !=
                null) {
          final data =
              Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value
                as Map,
          );

          balance =
              (data["balance"] ?? 0)
                  .toDouble();

          commission =
              (data["commission"] ?? 0)
                  .toDouble();

          phone = data["phone"] ?? "";
        }

        return Scaffold(
          appBar: AppBar(
            title:
                const Text("Wallet 💰"),
          ),
          body: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Balance: \$${balance.toStringAsFixed(2)}",
                  style:
                      const TextStyle(
                    fontSize: 24,
                  ),
                ),
                Text(
                  "Commission: \$${commission.toStringAsFixed(2)}",
                ),
                const SizedBox(
                    height: 20),
                ElevatedButton(
                  onPressed: () =>
                      showWithdrawForm(
                    balance,
                    phone,
                  ),
                  child:
                      const Text("Withdraw"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}