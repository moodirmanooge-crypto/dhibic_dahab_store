import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/wallet_service.dart';
import '../service/points_service.dart';
import '../service/notification_service.dart';

class MerchantOrders extends StatelessWidget {
  final String merchantId;

  const MerchantOrders({
    super.key,
    required this.merchantId,
  });

  String shortOrderId(String fullId) {
    if (fullId.length <= 4) return fullId;
    return fullId.substring(0, 4);
  }

  Future<void> approveOrder(
    BuildContext context,
    DocumentSnapshot orderDoc,
    Map<String, dynamic> data,
  ) async {
    final total =
        (data["total"] ?? 0).toDouble();

    await WalletService().updateWallet(
      merchantId,
      total,
    );

    await PointsService().addPoints(
      data["customerId"],
      total,
    );

    await orderDoc.reference.update({
      "status": "approved",
    });

    // ✅ Fixed: Maadaama saveAdminNotification uusan ku jirin NotificationService, 
    // waxaan si toos ah ugu kaydinaynaa Firestore si errors-ka u baxaan.
    await FirebaseFirestore.instance.collection("notifications").add({
      "department": "orders",
      "title": "Order Approved",
      "body": "Merchant approved order ${data["orderId"]}",
      "createdAt": FieldValue.serverTimestamp(),
      "isRead": false,
    });

    await NotificationService.showNotification(
      title: "Order Approved",
      body: "Customer order approved",
    );

    // ✅ Fixed: mounted check si looga saaro BuildContext async gap error
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Approved"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: const Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where(
              "merchantId",
              isEqualTo: merchantId,
            )
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

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet",
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder:
                (context, index) {
              final orderDoc =
                  orders[index];

              final data =
                  orderDoc.data()
                      as Map<String,
                          dynamic>;

              final total =
                  (data["total"] ?? 0)
                      .toDouble();

              final status =
                  data["status"] ??
                      "pending";

              final orderId =
                  data["orderId"] ??
                      orderDoc.id;

              return Card(
                margin:
                    const EdgeInsets.all(
                        10),
                child: Padding(
                  padding:
                      const EdgeInsets
                          .all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        data["productName"] ??
                            "",
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height: 6),
                      Text(
                          "Order ID: ${shortOrderId(orderId)}"),
                      Text(
                          "Qty: ${data["quantity"]}"),
                      Text(
                          "Customer: ${data["customerName"]}"),
                      Text(
                          "Phone: ${data["customerPhone"]}"),
                      Text(
                          "Location: ${data["customerLocation"]}"),
                      Text(
                        "Total: \$${total.toStringAsFixed(2)}",
                      ),
                      Text(
                        "Status: $status",
                        style:
                            TextStyle(
                          color: status ==
                                  "approved"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height: 12),
                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                status ==
                                        "approved"
                                    ? Colors
                                        .grey
                                    : Colors
                                        .green,
                          ),
                          onPressed:
                              status ==
                                      "approved"
                                  ? null
                                  : () =>
                                      approveOrder(
                                        context,
                                        orderDoc,
                                        data,
                                      ),
                          child: Text(
                            status ==
                                    "approved"
                                ? "Done"
                                : "Approve",
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
      ),
    );
  }
}