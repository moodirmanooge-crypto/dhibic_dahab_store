import 'package:flutter/material.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pickupController = TextEditingController();
    final dropController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: pickupController,
              decoration: const InputDecoration(
                labelText: 'Pickup Location',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dropController,
              decoration: const InputDecoration(
                labelText: 'Delivery Location',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery order sent to driver'),
                  ),
                );
              },
              child: const Text('Request Delivery'),
            ),
          ],
        ),
      ),
    );
  }
}
