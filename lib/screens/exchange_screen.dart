import 'package:flutter/material.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange Money"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              decoration: const InputDecoration(
                labelText: "From Currency",
              ),
            ),

            TextField(
              decoration: const InputDecoration(
                labelText: "To Currency",
              ),
            ),

            TextField(
              decoration: const InputDecoration(
                labelText: "Amount",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Exchange"),
            )

          ],
        ),
      ),
    );
  }
}