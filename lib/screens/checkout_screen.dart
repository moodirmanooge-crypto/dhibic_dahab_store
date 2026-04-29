import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final double price;

  // ✅ Waxaan ku daray 'Key' si looga saaro error-ka koowaad
  const CheckoutScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")), // ✅ const lagu daray
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ const lagu daray performance-ka awgeed
            const Text("Total Price", style: TextStyle(fontSize: 20)),

            const SizedBox(height: 10), // ✅ const lagu daray

            Text(
              "\$${price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 28, color: Colors.green), // ✅ const
            ),

            const SizedBox(height: 20), // ✅ const lagu daray

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order Placed ✅")), // ✅ const
                );
              },
              child: const Text("Confirm Order"), // ✅ const lagu daray
            )
          ],
        ),
      ),
    );
  }
}