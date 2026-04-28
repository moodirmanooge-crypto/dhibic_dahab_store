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
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final products =
            snapshot.data!.docs.where((doc) {
          final data =
              doc.data() as Map<String, dynamic>;

          if (data["deleted"] == true) {
            return false;
          }

          final name =
              data["name"]
                      ?.toString()
                      .toLowerCase() ??
                  "";

          final category =
              data["category"]
                      ?.toString()
                      .toLowerCase() ??
                  "";

          final matchSearch =
              searchText.isEmpty ||
                  name.contains(searchText);

          final matchCategory =
              selectedCategory == "all" ||
                  category ==
                      selectedCategory;

          return matchSearch &&
              matchCategory;
        }).toList();

        if (products.isEmpty) {
          return const Center(
            child: Text(
                "No products found"),
          );
        }

        return GridView.builder(
          padding:
              const EdgeInsets.all(10),
          itemCount: products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder:
              (context, index) {
            final doc =
                products[index];

            final data = doc.data()
                as Map<String, dynamic>;

            data["id"] = doc.id;

            final image =
                data["image"] ?? "";

            final price =
                double.tryParse(
                      data["price"]
                          .toString(),
                    ) ??
                    0;

            final discount =
                double.tryParse(
                      data["discount"]
                              ?.toString() ??
                          "0",
                    ) ??
                    0;

            final newPrice =
                discount > 0
                    ? price -
                        (price *
                            discount /
                            100)
                    : price;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetail(
                      product: data,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(18),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius
                                    .vertical(
                              top: Radius
                                  .circular(
                                      18),
                            ),
                            child: Image.network(
                              image,
                              width: double
                                  .infinity,
                              fit: BoxFit
                                  .cover,
                            ),
                          ),
                          if (discount > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      8,
                                  vertical:
                                      4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .red,
                                  borderRadius:
                                      BorderRadius.circular(
                                          8),
                                ),
                                child: Text(
                                  "${discount.toInt()}% OFF",
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white,
                                    fontSize:
                                        11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              data["name"] ??
                                  "",
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                                height: 6),
                            if (discount > 0)
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "\$${price.toStringAsFixed(2)}",
                                    style:
                                        const TextStyle(
                                      decoration:
                                          TextDecoration.lineThrough,
                                      color: Colors
                                          .grey,
                                    ),
                                  ),
                                  Text(
                                    "\$${newPrice.toStringAsFixed(2)}",
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .red,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .green,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
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