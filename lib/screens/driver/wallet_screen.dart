import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key}); // ✅ Saxid: Key lagu daray si looga saaro use_key_in_widget_constructors

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")), // ✅ Saxid: const lagu daray
      body: const Center( // ✅ Saxid: const lagu daray
        child: Text("Wallet Balance"), // ✅ Saxid: const lagu daray
      ),
    );
  }
}