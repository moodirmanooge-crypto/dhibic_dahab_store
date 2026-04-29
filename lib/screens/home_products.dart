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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .limit(30) // 🔥 muhiim (prevent heavy load)
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

            final price =
                double.tryParse(data["price"].toString()) ?? 0;

            // ✅ UPDATE: Merchant info direct from product data
            final merchantName =
                data["merchantName"] ?? "Store"; 

            final merchantImage =
                data["merchantImage"] ?? "";

            return GestureDetector(
              onTap: () {
                Map productData = Map.from(data);
                productData["id"] = doc.id;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetail(
                      product: productData,
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

                    // 🔥 IMAGE SAFE
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
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: Colors.grey,
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
                                backgroundImage: merchantImage.isNotEmpty
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
  }
}