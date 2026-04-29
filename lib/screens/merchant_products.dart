import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

class MerchantProducts extends StatelessWidget {
  final String merchantId;

  const MerchantProducts({
    super.key,
    required this.merchantId,
  });

  Future<double> getCategoryDiscount(
      String category) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("categories")
          .doc(category.toLowerCase())
          .get();

      if (!doc.exists) return 0;

      final data =
          doc.data() as Map<String, dynamic>;

      final discountText =
          data["discount"]?.toString() ?? "";

      return double.tryParse(
            discountText
                .replaceAll("%", "")
                .replaceAll("OFF", "")
                .trim(),
          ) ??
          0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteProduct(
    BuildContext context,
    DocumentReference ref,
    String productName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text(
          "Are you sure you want to delete $productName?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Ka hor inta aan la isticmaalin context ka dib 'await', waa in la hubiyaa haddii uu boggu furan yahay
    if (!context.mounted) return;

    await ref.delete();

    await NotificationService.showNotification(
      title: "Product Removed",
      body: "Merchant deleted product: $productName",
    );

    // Mar kale hubi context-ka ka hor inta aan SnackBar la tusin
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Product removed"),
      ),
    );
  }

  Widget buildPriceSection(
    double oldPrice,
    double discount,
  ) {
    double newPrice = oldPrice;

    if (discount > 0) {
      newPrice = oldPrice -
          (oldPrice * discount / 100);
    }

    return discount > 0
        ? Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "\$${oldPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  decoration:
                      TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "\$${newPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(
                              8),
                    ),
                    child: Text(
                      "${discount.toInt()}% OFF",
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Text(
            "\$${oldPrice.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F4DF),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: const Text(
          "My Products",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where(
              "merchantId",
              isEqualTo: merchantId,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final products =
              snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text(
                "No products yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                color:
                    Colors.amber.shade100,
                child: Text(
                  "Total Products: ${products.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      products.length,
                  itemBuilder:
                      (context, index) {
                    final doc =
                        products[index];

                    final raw =
                        doc.data();

                    if (raw
                        is! Map<String,
                            dynamic>) {
                      return const SizedBox();
                    }

                    final data = raw;

                    final name =
                        data["name"]
                                ?.toString() ??
                            "No Name";

                    final image =
                        data["image"]
                                ?.toString() ??
                            "";

                    final category =
                        data["category"]
                                ?.toString() ??
                            "";

                    final oldPrice =
                        double.tryParse(
                              data["price"]
                                  .toString(),
                            ) ??
                            0;

                    return FutureBuilder<
                        double>(
                      future:
                          getCategoryDiscount(
                              category),
                      builder: (
                        context,
                        discountSnap,
                      ) {
                        final discount =
                            discountSnap
                                    .data ??
                                0;

                        return Card(
                          margin:
                              const EdgeInsets
                                  .all(10),
                          elevation: 4,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets
                                    .all(10),
                            leading: image
                                    .isNotEmpty
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    child:
                                        Image.network(
                                      image,
                                      width:
                                          65,
                                      height:
                                          65,
                                      fit: BoxFit
                                          .cover,
                                      errorBuilder:
                                          (
                                        _,
                                        __,
                                        ___,
                                      ) {
                                        return const Icon(
                                          Icons
                                              .image,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 45,
                                  ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            subtitle:
                                buildPriceSection(
                              oldPrice,
                              discount,
                            ),
                            trailing:
                                IconButton(
                              icon:
                                  const Icon(
                                Icons
                                    .delete,
                                color:
                                    Colors.red,
                              ),
                              onPressed: () =>
                                  deleteProduct(
                                context,
                                doc.reference,
                                name,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}