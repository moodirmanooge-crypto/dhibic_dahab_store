import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'merchant_orders.dart';
import 'merchant_products.dart';
import 'withdraw_screen.dart';

class MerchantDashboard extends StatelessWidget {

  final String merchantId;
  final String merchantName;

  const MerchantDashboard({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  Future<void> uploadImage(BuildContext context) async {

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child("merchant_images")
        .child("$merchantId.jpg");

    await ref.putFile(file);

    String url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("merchant")
        .doc(merchantId)
        .update({
      "image": url
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile image updated")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(merchantName),
      ),

      body: StreamBuilder<DocumentSnapshot>(

        stream: FirebaseFirestore.instance
            .collection("merchant")
            .doc(merchantId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          String image = data["image"] ?? "";
          double wallet = (data["wallet"] ?? 0).toDouble();
          int commission = data["commission"] ?? 0;

          return ListView(

            padding: const EdgeInsets.all(20),

            children: [

              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      image != "" ? NetworkImage(image) : null,
                  child: image == ""
                      ? const Icon(Icons.store, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: (){
                  uploadImage(context);
                },
                child: const Text("Upload Profile Image"),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  merchantName,
                  style: const TextStyle(
                    fontSize:22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Wallet Balance",
                style: TextStyle(fontSize:18),
              ),

              const SizedBox(height:5),

              Text(
                "\$$wallet",
                style: const TextStyle(
                  fontSize:28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height:10),

              Text(
                "Commission: $commission%",
                style: const TextStyle(fontSize:16),
              ),

              const SizedBox(height:30),

              ElevatedButton.icon(

                icon: const Icon(Icons.add),

                label: const Text("Add Product"),

                onPressed: (){

                  Navigator.pushNamed(
                    context,
                    "/addProduct",
                    arguments: merchantId,
                  );

                },

              ),

              const SizedBox(height:10),

              ElevatedButton.icon(

                icon: const Icon(Icons.inventory),

                label: const Text("My Products"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_)=>MerchantProducts(
                        merchantId: merchantId,
                      ),
                    ),
                  );

                },

              ),

              const SizedBox(height:10),

              ElevatedButton.icon(

                icon: const Icon(Icons.shopping_cart),

                label: const Text("Orders"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_)=>MerchantOrders(
                        merchantId: merchantId,
                      ),
                    ),
                  );

                },

              ),

              const SizedBox(height:10),

              ElevatedButton.icon(

                icon: const Icon(Icons.account_balance_wallet),

                label: const Text("Withdraw Money"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_)=>WithdrawScreen(
                        merchantId: merchantId,
                      ),
                    ),
                  );

                },

              ),

            ],

          );

        },

      ),

    );
  }
}