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
  int step = 0; // 0 register, 1 exchange, 2 edit

  final amountController = TextEditingController();

  List<Map<String, dynamic>> formFields = [];
  List<Map<String, dynamic>> savedNumbers = [];

  String fromCompany = "Hormuud";
  String toCompany = "Somtel";

  double fee = 0;
  double total = 0;

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
    addField();
    checkUserData();
  }

  // ================= CONDITIONS =================
  String getCondition(String company) {
    switch (company) {
      case "Hormuud":
        return "Example: 25261xxxx or 25277xxxx";
      case "Somtel":
        return "Example: 25262xxxx";
      case "Somnet":
        return "Example: 25268xxxx";
      case "Premier":
        return "Example: 0025261xxxx";
      case "Somlink":
        return "Example: 25264xxxx";
      case "Amtel":
        return "Example: 25271xxxx";
      default:
        return "";
    }
  }

  // ================= VALIDATE =================
  String? validateNumber(String company, String number) {
    if (company == "Hormuud" &&
        !(number.startsWith("25261") || number.startsWith("25277"))) {
      return "Hormuud number qalad";
    }
    if (company == "Somtel" && !number.startsWith("25262")) {
      return "Somtel number qalad";
    }
    if (company == "Somnet" && !number.startsWith("25268")) {
      return "Somnet number qalad";
    }
    if (company == "Premier" && !number.startsWith("0025261")) {
      return "Premier number qalad";
    }
    if (company == "Somlink" && !number.startsWith("25264")) {
      return "Somlink number qalad";
    }
    if (company == "Amtel" && !number.startsWith("25271")) {
      return "Amtel number qalad";
    }
    return null;
  }

  // ================= CHECK USER =================
  Future<void> checkUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("exchange_users")
        .doc(user.uid)
        .get();

    if (!mounted) return; // Fix for use_build_context_synchronously

    if (doc.exists && doc.data()?["numbers"] != null) {
      savedNumbers = List<Map<String, dynamic>>.from(doc.data()!["numbers"]);
      setState(() => step = 1);
    } else {
      setState(() => step = 0);
    }
  }

  // ================= ADD FIELD =================
  void addField() {
    formFields.add({
      "company": companies[0],
      "controller": TextEditingController(),
    });
  }

  // ================= SAVE =================
  Future<void> saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> data = [];

    for (var item in formFields) {
      final number = item["controller"].text.trim();
      final company = item["company"];

      if (number.isNotEmpty) {
        final error = validateNumber(company, number);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
          return;
        }

        data.add({
          "company": company,
          "number": number,
        });
      }
    }

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geli ugu yaraan hal number")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("exchange_users")
        .doc(user.uid)
        .set({"numbers": data});

    if (!mounted) return; // Fix for use_build_context_synchronously

    savedNumbers = data;
    setState(() => step = 1);
  }

  // ================= GET NUMBER =================
  String getNumber(String company) {
    try {
      final found =
          savedNumbers.firstWhere((e) => e["company"] == company);
      return found["number"];
    } catch (_) {
      return "";
    }
  }

  // ================= CALCULATE =================
  void calculate() {
    final amount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      fee = amount * 0.02;
      total = amount - fee; 
    });
  }

  // ================= PAYMENT =================
  Future<void> makePayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final amount = double.tryParse(amountController.text) ?? 0;

    final senderNumber = getNumber(fromCompany);

    if (senderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No number for $fromCompany")),
      );
      return;
    }

    final res = await WaafiPaymentService.makePayment(
      phone: senderNumber,
      amount: amount,
      referenceId: DateTime.now().millisecondsSinceEpoch.toString(),
      description: "Exchange $fromCompany -> $toCompany",
    );

    if (!mounted) return; // Fix for use_build_context_synchronously

    final msg = res["responseMsg"]?.toLowerCase() ?? "";

    if (msg.contains("success") || msg.contains("approved")) {
      await FirebaseFirestore.instance
          .collection("exchange_orders")
          .add({
        "userId": user.uid,
        "fromCompany": fromCompany,
        "toCompany": toCompany,
        "senderNumber": senderNumber,
        "amount": amount,
        "fee": fee,
        "receive": total,
      });

      if (!mounted) return; // Re-check after firestore call

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Success ✅"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.toString())),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exchange Money")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: step == 0
            ? buildRegister()
            : step == 1
                ? buildExchange()
                : buildEdit(),
      ),
    );
  }

  // ================= REGISTER =================
  Widget buildRegister() {
    return Column(
      children: [
        const Text("Register Numbers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        Expanded(
          child: ListView.builder(
            itemCount: formFields.length,
            itemBuilder: (_, i) {
              final item = formFields[i];

              return Column(
                children: [
                  DropdownButtonFormField(
                    initialValue: item["company"], // 'value' changed to 'initialValue'
                    items: companies
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        item["company"] = v;
                      });
                    },
                  ),
                  TextField(
                    controller: item["controller"],
                    decoration: const InputDecoration(labelText: "Number"),
                  ),
                  Text(getCondition(item["company"]),
                      style: const TextStyle(color: Colors.grey)),
                  const Divider(),
                ],
              );
            },
          ),
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              addField();
            });
          },
          child: const Text("Add More"),
        ),

        ElevatedButton(
          onPressed: saveUserData,
          child: const Text("Save & Continue"),
        ),
      ],
    );
  }

  // ================= EXCHANGE =================
  Widget buildExchange() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => step = 2),
            child: const Text("Edit Connection"),
          ),
        ),

        DropdownButtonFormField(
          initialValue: fromCompany, // 'value' changed to 'initialValue'
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => fromCompany = v.toString()),
          decoration: const InputDecoration(labelText: "From"),
        ),

        DropdownButtonFormField(
          initialValue: toCompany, // 'value' changed to 'initialValue'
          items: companies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => toCompany = v.toString()),
          decoration: const InputDecoration(labelText: "To"),
        ),

        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount"),
          onChanged: (_) => calculate(),
        ),

        const SizedBox(height: 10),

        Text("Fee: \$${fee.toStringAsFixed(2)}"),
        Text("You receive: \$${total.toStringAsFixed(2)}"),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: makePayment,
          child: const Text("Send Money"),
        )
      ],
    );
  }

  // ================= EDIT =================
  Widget buildEdit() {
    return Column(
      children: [
        const Text("Edit Numbers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        Expanded(
          child: ListView.builder(
            itemCount: savedNumbers.length,
            itemBuilder: (_, i) {
              final item = savedNumbers[i];
              final controller =
                  TextEditingController(text: item["number"]);

              return Column(
                children: [
                  Text(item["company"]),
                  TextField(
                    controller: controller,
                    onChanged: (v) => item["number"] = v,
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),

        ElevatedButton(
          onPressed: () async {
            final uid = FirebaseAuth.instance.currentUser!.uid;

            await FirebaseFirestore.instance
                .collection("exchange_users")
                .doc(uid)
                .update({"numbers": savedNumbers});

            if (!mounted) return;

            setState(() => step = 1);
          },
          child: const Text("Save Changes"),
        )
      ],
    );
  }
}