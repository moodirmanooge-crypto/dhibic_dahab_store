import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .delete();
  }

  String formatSomaliaTime(dynamic timestamp) {
    try {
      if (timestamp == null) {
        return "Unknown time";
      }

      final date =
          (timestamp as Timestamp).toDate();

      final somaliaTime = date.toUtc().add(
        const Duration(hours: 3),
      );

      return DateFormat(
        "dd/MM/yyyy hh:mm a",
      ).format(somaliaTime);
    } catch (e) {
      return "Unknown time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("merchant")
            .snapshots(),
        builder: (context, merchantSnapshot) {
          if (!merchantSnapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final merchants =
              merchantSnapshot.data!.docs;

          return ListView(
            padding:
                const EdgeInsets.all(15),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(16),
                margin:
                    const EdgeInsets.only(
                        bottom: 15),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Text(
                  "Total Merchants: ${merchants.length}",
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              ...merchants.map((merchantDoc) {
                final merchant =
                    merchantDoc.data()
                        as Map<String,
                            dynamic>;

                final merchantId =
                    merchantDoc.id;

                final merchantName =
                    merchant["name"] ??
                        "Unknown Merchant";

                final merchantPhone =
                    merchant[
                            "merchantPhone"] ??
                        "No Phone";

                final merchantImage =
                    merchant["image"] ??
                        "";

                return Card(
                  margin:
                      const EdgeInsets.only(
                          bottom: 20),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  merchantImage
                                          .isNotEmpty
                                      ? NetworkImage(
                                          merchantImage)
                                      : null,
                              child: merchantImage
                                      .isEmpty
                                  ? const Icon(
                                      Icons
                                          .store)
                                  : null,
                            ),
                            const SizedBox(
                                width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    merchantName,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          20,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  Text(
                                    merchantPhone,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 15),

                        StreamBuilder<
                            QuerySnapshot>(
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
                          builder: (context,
                              productSnapshot) {
                            if (!productSnapshot
                                .hasData) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(),
                              );
                            }

                            final products =
                                productSnapshot
                                    .data!
                                    .docs;

                            if (products
                                .isEmpty) {
                              return const Text(
                                "No products",
                              );
                            }

                            return Column(
                              children: products
                                  .map((doc) {
                                final product =
                                    doc.data() as Map<
                                        String,
                                        dynamic>;

                                final productId =
                                    doc.id;

                                final image =
                                    product["image"] ??
                                        "";

                                final title =
                                    product["name"] ??
                                        "Unknown";

                                final price =
                                    product["price"] ??
                                        0;

                                final description =
                                    product["description"] ??
                                        "";

                                final createdAt =
                                    formatSomaliaTime(
                                  product[
                                      "createdAt"],
                                );

                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                          bottom:
                                              12),
                                  padding:
                                      const EdgeInsets.all(
                                          10),
                                  decoration:
                                      BoxDecoration(
                                    color: const Color(
                                        0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(
                                            15),
                                  ),
                                  child:
                                      Column(
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                            child: Image.network(
                                              image,
                                              width:
                                                  70,
                                              height:
                                                  70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  10),
                                          Expanded(
                                            child:
                                                Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize:
                                                        18,
                                                  ),
                                                ),
                                                Text(
                                                    "Price: \$$price"),
                                                Text(
                                                    createdAt),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              10),
                                      Align(
                                        alignment:
                                            Alignment.centerLeft,
                                        child:
                                            Text(
                                          description,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              10),
                                      ElevatedButton(
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.red,
                                        ),
                                        onPressed:
                                            () {
                                          deleteProduct(
                                              productId);
                                        },
                                        child:
                                            const Text(
                                          "Delete Product",
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}