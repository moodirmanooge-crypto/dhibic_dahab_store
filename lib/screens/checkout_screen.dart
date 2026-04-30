import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../screens/payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final double price;

  const CheckoutScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Total Price",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              "\$${price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 28,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      book: Book(
                        id: "order_checkout",
                        title: "Cart Payment",
                        price: price,
                        pdfUrl: "",
                        coverImage: "", // Halkan ayaan ku daray xariiqdan maqnaa
                      ),
                    ),
                  ),
                );
              },
              child: const Text("Confirm Order"),
            ),
          ],
        ),
      ),
    );
  }
}