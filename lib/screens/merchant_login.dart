import 'package:flutter/material.dart';
import 'merchant_dashboard.dart';

class MerchantLogin extends StatefulWidget {
  const MerchantLogin({super.key});

  @override
  State<MerchantLogin> createState() => _MerchantLoginState();
}

class _MerchantLoginState extends State<MerchantLogin> {

  final idController = TextEditingController();
  final nameController = TextEditingController();

  void loginMerchant(){

    String merchantId = idController.text.trim();
    String merchantName = nameController.text.trim();

    if(merchantId.isEmpty || merchantName.isEmpty){
      return;
    }

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>MerchantDashboard(
          merchantId: merchantId,
          merchantName: merchantName,
        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Merchant Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: "Merchant ID",
              ),
            ),

            const SizedBox(height:20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Merchant Name",
              ),
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: loginMerchant,
              child: const Text("Login"),
            )

          ],

        ),

      ),

    );

  }

}