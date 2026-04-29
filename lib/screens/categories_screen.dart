import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_merchants_screen.dart';
import '../widgets/cart_icon.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // Function-ka soo saaraya Icon-ka saxda ah ee qayb kasta
  IconData getCategoryIcon(String key) {
    switch (key.toLowerCase()) {
      case "restaurants":
        return Icons.restaurant;
      case "clothes":
        return Icons.checkroom;
      case "supermarket":
      case "supermarkets":
        return Icons.shopping_cart;
      case "electronics":
        return Icons.devices;
      case "pharmacy":
        return Icons.local_hospital;
      case "companies":
        return Icons.business;
      case "organics":
        return Icons.eco;
      case "machines":
        return Icons.precision_manufacturing;
      default:
        return Icons.category;
    }
  }

  // Check-gareynta haddii category-gu leeyahay Discount
  bool hasDiscount(Map<String, dynamic> data) {
    final discount = data["discount"]?.toString().trim() ?? "";
    return discount.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE7F6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        actions: const [
          CartIcon(),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .where("isActive", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No categories found"),
            );
          }

          final allDocs = snapshot.data!.docs;

          // Shaandheynta (Filtering): Waxaan soo saareynaa kaliya kuwa leh Discount,
          // waxaana ka saareynaa category-ga "reading".
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (doc.id == "reading") {
              return false;
            }

            return hasDiscount(data);
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text("No discounted categories found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final categoryKey = doc.id;

              return GestureDetector(
                onTap: () {
                  // ✅ U gudubka liiska Merchant-yada ee category-gan hoostaga
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryMerchantsScreen(
                        category: categoryKey,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37), // Midabka Dahabka (Dhibic Dahab)
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        // ✅ Saxid: withOpacity waxaa loo beddelay withValues
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          // ✅ Saxid: withOpacity waxaa loo beddelay withValues
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          getCategoryIcon(categoryKey),
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["name"] ?? "",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["description"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                // ✅ Saxid: withOpacity waxaa loo beddelay withValues
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "🔥 ${data["discount"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}