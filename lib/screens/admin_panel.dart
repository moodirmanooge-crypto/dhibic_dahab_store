import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/admin_users_screen.dart';
import 'admin/admin_merchants_screen.dart';
import 'admin/admin_books_screen.dart';
import 'admin/admin_products_screen.dart';
import 'admin/admin_exchange_screen.dart';
import 'admin/admin_driver_orders_screen.dart';
import 'admin/sales_report_screen.dart';

// ⚠️ haddii file-kan jiro ha ka saarin comment
// import 'admin/admin_ads_screen.dart';

import '../service/notification_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  void initState() {
    super.initState();

    // 🔔 Listen notifications (safe)
    FirebaseFirestore.instance
        .collection("notifications")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        try {
          NotificationService.showNotification(
            title: data["title"] ?? "New Notification",
            body: data["body"] ?? "",
          );
        } catch (e) {
          debugPrint("Notification error: $e");
        }
      }
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // ✅ Waxaan xaqiijinaynaa in context-ku uu weli jiro (Safe navigation)
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          adminButton(context, "All Orders", Icons.shopping_cart, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminOrdersScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "All Users", Icons.people, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminUsersScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "All Merchants", Icons.store, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminMerchantsScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "All Products", Icons.inventory_2, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminProductsScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          // ❌ haddii file-kan maqan yahay, ha isticmaalin
          /*
          adminButton(context, "All Ads", Icons.campaign, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminAdsScreen(),
              ),
            );
          }),
          */

          adminButton(context, "All Books", Icons.book, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminBooksScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "Exchange Money", Icons.currency_exchange, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminExchangeScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "Driver Orders", Icons.delivery_dining, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDriverOrdersScreen(),
              ),
            );
          }),

          const SizedBox(height: 15),

          adminButton(context, "Sales Report", Icons.bar_chart, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SalesReportScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget adminButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 70),
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 26),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}