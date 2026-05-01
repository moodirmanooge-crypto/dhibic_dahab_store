import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_detail.dart';

class HomeProducts extends StatelessWidget {
  final String searchText;
  final String selectedCategory;

  const HomeProducts({
    super.key,
    required this.searchText,
    required this.selectedCategory,
  });

  Future<void> addToCart(BuildContext context, String docId, Map<String, dynamic> data) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("cart")
        .doc(userId)
        .collection("items")
        .doc(docId)
        .set({
      "name": data["name"],
      "price": data["price"],
      "image": data["image"],
      "quantity": 1,

      // 🔥 muhiim (merchant data si order u shaqeeyo)
      "merchantId": data["merchantId"] ?? "",
      "merchantName": data["merchantName"] ?? "",
      "merchantPhone": data["merchantPhone"] ?? "",
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .limit(30)
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
            childAspectRatio: 0.58,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;

            final price =
                double.tryParse(data["price"].toString()) ?? 0;

            final merchantName =
                data["merchantName"] ?? "Store"; 

            final merchantImage =
                data["merchantImage"] ?? "";

            return Container(
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

                  // 🔥 IMAGE CLICK → DETAIL
                  GestureDetector(
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
                    child: ClipRRect(
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
                          style: const TextStyle(
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

                  // 🔥 ADD TO CART BUTTON (NEW)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          addToCart(context, doc.id, data);
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        );
      },
    );
  }
}