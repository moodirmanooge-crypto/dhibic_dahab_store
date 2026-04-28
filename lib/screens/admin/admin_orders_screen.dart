import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .update({
      "status": status,
    });
  }

  Future<void> deleteOrder(
    String orderId,
  ) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .delete();
  }

  Future<Map<String, dynamic>?> getMerchantData(
    String merchantId,
  ) async {
    try {
      final doc = await FirebaseFirestore
          .instance
          .collection("merchant")
          .doc(merchantId)
          .get();

      if (doc.exists) {
        return doc.data();
      }

      return null;
    } catch (e) {
      return null;
    }
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

  String getMerchantApprovalText(
      Map<String, dynamic> data) {
    final approvals =
        data["merchantApprovals"] ?? 0;

    final totalMerchants =
        data["totalMerchants"] ?? 1;

    if (approvals == totalMerchants) {
      return "All merchants approved";
    }

    return "$approvals merchant approval";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text("All Orders"),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy(
              "createdAt",
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final orders =
              snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder:
                (context, index) {
              final doc = orders[index];

              final data = doc.data()
                  as Map<String, dynamic>;

              final orderId = doc.id;

              final customerPhone =
                  data["customerPhone"] ??
                      "No phone";

              final customerImage =
                  data["profileImage"] ??
                      "";

              final merchantId =
                  data["merchantId"] ?? "";

              final productName =
                  data["productName"] ??
                      "Unknown Product";

              final productImage =
                  data["image"] ?? "";

              final quantity =
                  data["quantity"] ?? 1;

              final price =
                  data["price"] ?? 0;

              final total =
                  data["total"] ?? 0;

              final status =
                  data["status"] ??
                      "pending";

              final createdAt =
                  formatSomaliaTime(
                data["createdAt"],
              );

              final approvalText =
                  getMerchantApprovalText(
                      data);

              final paymentNumber = data[
                          "paymentResponse"]?[
                      "params"]?[
                  "accountNo"] ??
                  "No payment number";

              return FutureBuilder<
                  Map<String, dynamic>?>(
                future: getMerchantData(
                    merchantId),
                builder: (context,
                    merchantSnap) {
                  final merchant =
                      merchantSnap.data;

                  final merchantName =
                      merchant?["name"] ??
                          data["merchantName"] ??
                          "Unknown Merchant";

                  final merchantPhone =
                      merchant?[
                              "merchantPhone"] ??
                          data["merchantPhone"] ??
                          "No phone";

                  final merchantImage =
                      merchant?["image"] ??
                          "";

                  return Card(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(20),
                    ),
                    margin:
                        const EdgeInsets.only(
                            bottom: 20),
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(15),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    customerImage
                                            .isNotEmpty
                                        ? NetworkImage(
                                            customerImage)
                                        : null,
                                child:
                                    customerImage
                                            .isEmpty
                                        ? const Icon(
                                            Icons
                                                .person)
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
                                    const Text(
                                      "Customer",
                                      style:
                                          TextStyle(
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    Text(
                                        customerPhone),
                                    Text(
                                      "Payment: $paymentNumber",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 12),
                          Text(
                            createdAt,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const Divider(),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage:
                                    merchantImage
                                            .isNotEmpty
                                        ? NetworkImage(
                                            merchantImage)
                                        : null,
                                child:
                                    merchantImage
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
                                            17,
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

                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                                child:
                                    Image.network(
                                  productImage,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit
                                      .cover,
                                ),
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
                                      productName,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    Text(
                                      "Qty: $quantity",
                                    ),
                                    Text(
                                      "Price: \$$price",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 12),
                          Text(
                            "Total: \$$total",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          Text(
                              "Status: $status"),
                          Text(approvalText),

                          const SizedBox(
                              height: 12),

                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateOrderStatus(
                                    orderId,
                                    "delivered",
                                  );
                                },
                                child:
                                    const Text(
                                  "Delivered",
                                ),
                              ),
                              const SizedBox(
                                  width: 10),
                              ElevatedButton(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                ),
                                onPressed: () {
                                  deleteOrder(
                                      orderId);
                                },
                                child:
                                    const Text(
                                  "Delete",
                                ),
                              ),
                            ],
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
      ),
    );
  }
}