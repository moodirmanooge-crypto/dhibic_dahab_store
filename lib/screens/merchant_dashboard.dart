import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'merchant_orders.dart';
import 'merchant_products.dart';
import 'withdraw_screen.dart';
import 'main_screen.dart';
import 'chat/merchant_chat_list.dart';
import 'add_product_screen.dart'; // 🔥 muhiim

class MerchantDashboard extends StatelessWidget {
  final String merchantId;
  final String merchantName;

  const MerchantDashboard({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  Future<void> uploadImage(BuildContext context) async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child("merchant_images/$merchantId.jpg");

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("merchant")
        .doc(merchantId)
        .update({"image": url});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  Future<void> uploadPromoAd(BuildContext context) async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child("promo_ads/$merchantId.jpg");

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("promo_ads").doc(merchantId).set({
      "merchantId": merchantId,
      "merchantName": merchantName,
      "image": url,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Promo uploaded")),
    );
  }

  Widget goldButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: Icon(icon),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Merchant Dashboard"),
        backgroundColor: const Color(0xFFD4AF37),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          },
        ),
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

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final image = data["image"] ?? "";
          final wallet = (data["wallet"] ?? 0).toDouble();
          final commission = data["commission"] ?? 10;

          final category = data["category"] ?? "clothes_women";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      image.isNotEmpty ? NetworkImage(image) : null,
                  child: image.isEmpty
                      ? const Icon(Icons.store, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 15),

              goldButton(
                icon: Icons.image,
                text: "Upload Profile Image",
                onTap: () => uploadImage(context),
              ),

              const SizedBox(height: 10),

              goldButton(
                icon: Icons.campaign,
                text: "Upload Promo Ad",
                onTap: () => uploadPromoAd(context),
              ),

              const SizedBox(height: 30),

              Text(
                "Wallet: \$${wallet.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Text("Commission: $commission%"),

              const SizedBox(height: 30),

              // 🔥 FIXED ADD PRODUCT BUTTON
              goldButton(
                icon: Icons.add,
                text: "Add Product",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductScreen(
                        merchantId: merchantId,
                        category: category,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              goldButton(
                icon: Icons.inventory,
                text: "My Products",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MerchantProducts(merchantId: merchantId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              goldButton(
                icon: Icons.shopping_cart,
                text: "Orders",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MerchantOrders(merchantId: merchantId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              goldButton(
                icon: Icons.chat,
                text: "Customer Chats",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MerchantChatList(
                        merchantId: merchantId,
                        merchantName: merchantName,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              goldButton(
                icon: Icons.wallet,
                text: "Withdraw Money",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WithdrawScreen(merchantId: merchantId),
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