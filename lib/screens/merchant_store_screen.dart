import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail.dart';

class MerchantStoreScreen extends StatelessWidget {
  final String merchantId;

  const MerchantStoreScreen({
    super.key,
    required this.merchantId,
  });

  Future<double> getCategoryDiscount(
      String category) async {
    final doc = await FirebaseFirestore.instance
        .collection("categories")
        .doc(category.toLowerCase())
        .get();

    if (!doc.exists) return 0;

    final data = doc.data() as Map<String, dynamic>;

    final discountText =
        data["discount"]?.toString() ?? "";

    return double.tryParse(
          discountText
              .replaceAll("%", "")
              .replaceAll("OFF", "")
              .trim(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store"),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("merchant")
                .doc(merchantId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              var raw =
                  snapshot.data!.data();

              if (raw
                  is! Map<String, dynamic>) {
                return const SizedBox();
              }

              var data = raw;

              String name =
                  data["name"]
                          ?.toString() ??
                      "";

              String image =
                  data["image"]
                          ?.toString() ??
                      "";

              return Column(
                children: [
                  const SizedBox(
                      height: 10),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        image.isNotEmpty
                            ? NetworkImage(
                                image)
                            : null,
                    child: image.isEmpty
                        ? const Icon(
                            Icons.store)
                        : null,
                  ),
                  const SizedBox(
                      height: 10),
                  Text(
                    name,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 20),
                ],
              );
            },
          ),
          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore
                      .instance
                      .collection(
                          "products")
                      .where(
                        "merchantId",
                        isEqualTo:
                            merchantId,
                      )
                      .snapshots(),
              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                var products = snapshot
                    .data!.docs
                    .where((doc) {
                  final data = doc.data()
                      as Map<String,
                          dynamic>;
                  return data[
                          "deleted"] !=
                      true;
                }).toList();

                if (products.isEmpty) {
                  return const Center(
                    child:
                        Text("No products"),
                  );
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets
                          .all(10),
                  itemCount:
                      products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        0.72,
                    crossAxisSpacing:
                        10,
                    mainAxisSpacing:
                        10,
                  ),
                  itemBuilder:
                      (context, index) {
                    var doc =
                        products[index];

                    var raw =
                        doc.data();

                    if (raw
                        is! Map<String,
                            dynamic>) {
                      return const SizedBox();
                    }

                    var data = raw;

                    data["id"] =
                        doc.id;

                    String category =
                        data["category"]
                                ?.toString() ??
                            "";

                    return FutureBuilder<
                        double>(
                      future:
                          getCategoryDiscount(
                              category),
                      builder: (
                        context,
                        discountSnap,
                      ) {
                        if (!discountSnap
                            .hasData) {
                          return const SizedBox();
                        }

                        final discount =
                            discountSnap
                                    .data ??
                                0;

                        String name =
                            data["name"]
                                    ?.toString() ??
                                "";

                        String image =
                            data["image"]
                                    ?.toString() ??
                                "";

                        double oldPrice =
                            double.tryParse(
                                  data["price"]
                                      .toString(),
                                ) ??
                                0;

                        double newPrice =
                            oldPrice;

                        if (discount >
                            0) {
                          newPrice =
                              oldPrice -
                                  (oldPrice *
                                      discount /
                                      100);
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProductDetail(
                                  product:
                                      data,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      image
                                              .isNotEmpty
                                          ? Image.network(
                                              image,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : const Icon(
                                              Icons.image,
                                              size: 80,
                                            ),
                                      if (discount >
                                          0)
                                        Positioned(
                                          top:
                                              8,
                                          right:
                                              8,
                                          child:
                                              Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal:
                                                  10,
                                              vertical:
                                                  5,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),
                                            child:
                                                Text(
                                              "${discount.toInt()}% OFF",
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  name,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                discount > 0
                                    ? Column(
                                        children: [
                                          Text(
                                            "\$${oldPrice.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "\$${newPrice.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "\$${oldPrice.toStringAsFixed(2)}",
                                      ),
                                const SizedBox(
                                    height:
                                        10),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}