import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

class MerchantProductsScreen extends StatelessWidget {
  final String merchantId;
  final String merchantName;
  final String category;

  const MerchantProductsScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.category,
  });

  Future<double> getCategoryDiscount() async {
    try {
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
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteProduct(
    BuildContext context,
    String docId,
    String productName,
  ) async {
    await FirebaseFirestore.instance
        .collection("products")
        .doc(docId)
        .delete();

    // ✅ FIXED: Hadda waxaan isticmaaleynaa service-ka si import-ka uusan "unused" u noqon
    await NotificationService().saveAdminNotification(
      "Product Deleted",
      "$merchantName removed product: $productName",
    );

    // ✅ FIXED: mounted check si looga saaro BuildContext async gap error
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Product deleted"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: Text(merchantName),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/addProduct",
            arguments: {
              "merchantId": merchantId,
              "category": category,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<double>(
        future: getCategoryDiscount(),
        builder: (context, discountSnap) {
          if (!discountSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final discount =
              discountSnap.data ?? 0;

          return StreamBuilder<QuerySnapshot>(
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
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text("No products found"),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder:
                    (context, index) {
                  final doc = docs[index];
                  final data =
                      doc.data()
                          as Map<String,
                              dynamic>;

                  final name =
                      data["name"] ??
                          "No Name";

                  final image =
                      data["image"] ??
                          "";

                  final oldPrice =
                      double.tryParse(
                            data["price"]
                                .toString(),
                          ) ??
                          0;

                  final newPrice =
                      oldPrice -
                          (oldPrice *
                              discount /
                              100);

                  return Card(
                    margin:
                        const EdgeInsets
                            .all(10),
                    child: ListTile(
                      leading: image
                              .toString()
                              .isNotEmpty
                          ? Image.network(
                              image,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.image,
                            ),
                      title: Text(name),
                      subtitle: discount > 0
                          ? Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "\$${oldPrice.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    decoration:
                                        TextDecoration
                                            .lineThrough,
                                  ),
                                ),
                                Text(
                                  "\$${newPrice.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.red,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "\$${oldPrice.toStringAsFixed(2)}",
                            ),
                      trailing:
                          IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            deleteProduct(
                          context,
                          doc.id,
                          name,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}