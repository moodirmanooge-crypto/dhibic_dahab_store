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

  String shortOrderId(String id) =>
      id.length > 4 ? id.substring(0, 4) : id;

  String formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final d = ts.toDate();
    return "${d.day}/${d.month}/${d.year} - ${d.hour}:${d.minute}";
  }

  Future<void> approveOrder(
    BuildContext context,
    DocumentSnapshot orderDoc,
    Map<String, dynamic> data,
  ) async {
    double total = (data["total"] ?? 0).toDouble();

    await WalletService().updateWallet(merchantId, total);
    await PointsService().addPoints(data["customerId"], total);

    await orderDoc.reference.update({"status": "approved"});

    await NotificationService.showNotification(
      title: "Order Approved",
      body: "Order Approved",
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Approved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: const Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("merchantId", isEqualTo: merchantId)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final data = orderDoc.data() as Map<String, dynamic>;

              final status = data["status"] ?? "pending";
              final orderId = data["orderId"] ?? "";

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(data["productName"] ?? "",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),

                      Text("Order ID: ${shortOrderId(orderId)}"),
                      Text("Qty: ${data["quantity"]}"),
                      Text(
                        "Total: \$${(data["total"] ?? 0).toString()}",
                      ),

                      const Divider(),

                      Text("Sender: ${data["senderPhone"] ?? ""}"),
                      Text("Receiver: ${data["receiverPhone"] ?? ""}"),
                      Text("Address: ${data["address"] ?? ""}"),
                      Text("Type: ${data["deliveryType"] ?? ""}"),

                      Text(
                        "Date: ${formatTime(data["createdAt"])}",
                        style: const TextStyle(fontSize: 12),
                      ),

                      const Divider(),

                      // 🔥 OTHER MERCHANTS
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("orders")
                            .where("orderId", isEqualTo: orderId)
                            .get(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox();

                          final list = snap.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Other Merchants:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),

                              ...list.map((doc) {
                                final d = doc.data()
                                    as Map<String, dynamic>;

                                if (d["merchantId"] == merchantId) {
                                  return const SizedBox();
                                }

                                return ListTile(
                                  leading: d["image"] != null
                                      ? Image.network(d["image"],
                                          width: 40, height: 40)
                                      : const Icon(Icons.store),

                                  title: Text(d["merchantName"] ?? ""),
                                  subtitle: Text(d["merchantPhone"] ?? ""),

                                  trailing: Text(
                                    d["status"] ?? "",
                                    style: TextStyle(
                                      color: d["status"] == "approved"
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: status == "approved"
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: status == "approved"
                            ? null
                            : () => approveOrder(
                                  context,
                                  orderDoc,
                                  data,
                                ),
                        child: Text(
                            status == "approved" ? "Done" : "Approve"),
                      )
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