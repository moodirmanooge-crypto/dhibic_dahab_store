import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail.dart';

class HomeProducts extends StatelessWidget {
  final String searchText;
  final String selectedCategory;

  const HomeProducts({
    super.key,
    required this.searchText,
    required this.selectedCategory,
  });

  Future<Map<String, dynamic>?> getMerchant(String merchantId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("merchant")
          .doc(merchantId)
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading products"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        final query = searchText.toLowerCase().trim();

        final products = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final name = data["name"]?.toString().toLowerCase() ?? "";
          final category = data["category"]?.toString().toLowerCase() ?? "";

          final matchSearch = query.isEmpty ||
              name.contains(query) ||
              category.contains(query);

          final matchCategory =
              selectedCategory.toLowerCase() == "all" ||
                  category == selectedCategory.toLowerCase();

          return matchSearch && matchCategory;
        }).toList();

        if (products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;

            final merchantId = data["merchantId"] ?? "";

            final price =
                double.tryParse(data["price"].toString()) ?? 0;

            return FutureBuilder<Map<String, dynamic>?>(
              future: getMerchant(merchantId),
              builder: (context, merchantSnap) {
                final merchant = merchantSnap.data;

                final merchantName =
                    merchant?["merchantName"] ?? "Store";

                final merchantImage =
                    merchant?["image"] ?? "";

                return GestureDetector(
                  onTap: () {
                    // Waxaan isku xidhnay xogta iyo waxa uu filayo ProductDetail
                    Map productData = Map.from(data);
                    productData["id"] = doc.id;
                    productData["merchantName"] = merchantName;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetail(
                          product: productData, // 🔥 FIX: Kani waa magaca saxda ah
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: Image.network(
                              data["image"] ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 40),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["name"] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                data["description"] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage:
                                        merchantImage.isNotEmpty
                                            ? NetworkImage(merchantImage)
                                            : null,
                                    child: merchantImage.isEmpty
                                        ? const Icon(Icons.store, size: 12)
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      merchantName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}