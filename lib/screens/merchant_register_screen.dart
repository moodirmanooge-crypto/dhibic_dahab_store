import 'package:flutter/material.dart';

class MerchantRegisterScreen extends StatelessWidget {
  const MerchantRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Register')),
      body: const Column(
        children: [
          TextField(decoration: InputDecoration(labelText: 'Shop Name')),
          TextField(decoration: InputDecoration(labelText: 'Phone')),
          TextField(decoration: InputDecoration(labelText: 'Password')),
        ],
      ),
    );
  }
}
