import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'pdf_viewer.dart';

class PaymentScreen extends StatefulWidget {

  final String bookId;
  final String pdfUrl;
  final double price;

  const PaymentScreen({
    super.key,
    required this.bookId,
    required this.pdfUrl,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  final phoneController = TextEditingController();

  bool loading = false;

  Future pay() async {

    setState(() {
      loading = true;
    });

    try {

      final result = await FirebaseFunctions.instance
          .httpsCallable('payWithEVC')
          .call({
        "phone": phoneController.text,
        "amount": widget.price,
        "bookId": widget.bookId
      });

      if (result.data["success"]) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewer(url: widget.pdfUrl),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed")),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment error")),
      );

    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Payment")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Enter EVC number",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : pay,
              child: Text("Pay \$${widget.price}"),
            )

          ],

        ),

      ),

    );

  }

}