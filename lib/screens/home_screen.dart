import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'home_products.dart';
import 'merchant_login.dart';
import 'register_login.dart';
import 'chat/chat_list_screen.dart';
import 'cart_screen.dart';

import '../widgets/cart_icon.dart';
import '../widgets/promo_popup_widget.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";

  Widget buildDiscountBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("merchant")
          .where("isDiscountActive", isEqualTo: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final data =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;

        final merchantName = data["name"]?.toString() ?? "";
        final merchantImage = data["image"]?.toString() ?? "";
        final discount = data["discountPercent"] ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("🔥 $discount% OFF"),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: merchantImage.isNotEmpty
                    ? Image.network(
                        merchantImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.store),
                      )
                    : const Icon(Icons.store),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showAdminPasswordDialog() async {
    final controller = TextEditingController();
    bool shouldNavigate = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Admin Password"),
          content: TextField(
            controller: controller,
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final snap = await FirebaseFirestore.instance
                    .collection("settings")
                    .doc("admin_access")
                    .get();

                final password =
                    snap.data()?["registerPassword"]?.toString() ?? "";

                if (controller.text.trim() == password) {
                  shouldNavigate = true;
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (shouldNavigate && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterLogin(),
        ),
      );
    }
  }

  void handleMenu(String value) {
    if (value == "merchant_login") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MerchantLogin(),
        ),
      );
    }

    if (value == "register_login") {
      showAdminPasswordDialog();
    }

    if (value == "support_chat") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatListScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: const Text("Dhibic Dahab"),
        actions: [
          const CartIcon(),
          PopupMenuButton<String>(
            onSelected: handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "merchant_login",
                child: Text("Merchant Login"),
              ),
              PopupMenuItem(
                value: "register_login",
                child: Text("Register Merchant"),
              ),
              PopupMenuItem(
                value: "support_chat",
                child: Text("Customer Support"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.topRight,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xFF8E44AD),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
            child: const Icon(Icons.shopping_cart),
          ),
          if (cart.itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cart.itemCount.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF8E1),
                    Color(0xFFD4AF37),
                  ],
                ),
              ),
              child: Column(
                children: [
                  buildDiscountBanner(),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        try {
                          return HomeProducts(
                            searchText: searchText,
                            selectedCategory: "all",
                          );
                        } catch (e) {
                          return const Center(
                            child: Text("Error loading products"),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: PromoPopupWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}