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

  Future<Map<String, dynamic>?> getMerchant(
      String merchantId) async {
    final doc = await FirebaseFirestore.instance
        .collection("merchant")
        .doc(merchantId)
        .get();

    if (!doc.exists) return null;
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .orderBy("createdAt", descending: true) // 🔥 NEW FIRST
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final query = searchText.toLowerCase().trim();

        final products = snapshot.data!.docs.where((doc) {
          final data =
              doc.data() as Map<String, dynamic>;

          final name =
              data["name"]?.toString().toLowerCase() ??
                  "";

          final category =
              data["category"]
                      ?.toString()
                      .toLowerCase() ??
                  "";

          final matchSearch =
              query.isEmpty ||
                  name.contains(query) ||
                  category.contains(query);

          final matchCategory =
              selectedCategory.toLowerCase() == "all" ||
                  category ==
                      selectedCategory.toLowerCase();

          return matchSearch && matchCategory;
        }).toList();

        if (products.isEmpty) {
          return const Center(
            child: Text("No products found"),
          );
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
            final data =
                doc.data() as Map<String, dynamic>;

            final merchantId = data["merchantId"] ?? "";

            return FutureBuilder<Map<String, dynamic>?>(
              future: getMerchant(merchantId),
              builder: (context, merchantSnap) {
                if (!merchantSnap.hasData) {
                  return const SizedBox();
                }

                final merchant = merchantSnap.data;

                final merchantName =
                    merchant?["merchantName"] ?? "Store";

                final merchantImage =
                    merchant?["image"] ?? "";

                final price = double.tryParse(
                        data["price"].toString()) ??
                    0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetail(product: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // 🔥 IMAGE
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: Image.network(
                              data["image"] ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // 🔥 PRODUCT NAME
                              Text(
                                data["name"] ?? "",
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // 🔥 DESCRIPTION
                              Text(
                                data["description"] ?? "",
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // 🔥 PRICE
                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // 🔥 MERCHANT INFO
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage:
                                        merchantImage != ""
                                            ? NetworkImage(
                                                merchantImage)
                                            : null,
                                    child: merchantImage == ""
                                        ? const Icon(
                                            Icons.store,
                                            size: 12,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      merchantName,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
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