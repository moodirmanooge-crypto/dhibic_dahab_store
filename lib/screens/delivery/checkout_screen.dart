import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final double price;

  const CheckoutScreen({required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Total Price", style: TextStyle(fontSize: 20)),

            SizedBox(height: 10),

            Text("\$${price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 28, color: Colors.green)),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Order Placed ✅")),
                );
              },
              child: Text("Confirm Order"),
            )
          ],
        ),
      ),
    );
  }
}