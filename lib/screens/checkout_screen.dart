import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    const deliveryFee = 5.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Text('Products total: \$${cart.totalPrice}'),
          const Text('Delivery: \$5'),
          Text('Grand Total: \$${cart.totalPrice + deliveryFee}'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    amount: cart.totalPrice + deliveryFee,
                  ),
                ),
              );
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }
}
