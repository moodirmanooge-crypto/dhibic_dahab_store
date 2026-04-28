import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminExchangeScreen extends StatelessWidget {
  const AdminExchangeScreen({super.key});

  Future<void> approveExchange(
    String exchangeId,
  ) async {
    await FirebaseFirestore.instance
        .collection("exchange_orders")
        .doc(exchangeId)
        .update({
      "status": "approved",
      "approvedAt":
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExchange(
    String exchangeId,
  ) async {
    await FirebaseFirestore.instance
        .collection("exchange_orders")
        .doc(exchangeId)
        .delete();
  }

  String formatSomaliaTime(
    dynamic timestamp,
  ) {
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
        title:
            const Text("All Exchange Money"),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("exchange_orders")
            .orderBy(
              "createdAt",
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading exchange orders",
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final exchanges =
              snapshot.data!.docs;

          if (exchanges.isEmpty) {
            return const Center(
              child: Text(
                "No exchange orders yet",
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(15),
            itemCount: exchanges.length,
            itemBuilder:
                (context, index) {
              final doc = exchanges[index];

              final data = doc.data()
                  as Map<String, dynamic>;

              final exchangeId = doc.id;

              final customerEmail =
                  data["email"] ??
                      data["customerEmail"] ??
                      "No email";

              final customerImage =
                  data["profileImage"] ??
                      data["image"] ??
                      "";

              final senderNumber =
                  data["senderNumber"] ??
                      data["fromNumber"] ??
                      "Unknown";

              final receiverNumber =
                  data["receiverNumber"] ??
                      data["toNumber"] ??
                      "Unknown";

              final amount =
                  data["amount"] ?? 0;

              final status =
                  data["status"] ??
                      "pending";

              final createdAt =
                  formatSomaliaTime(
                data["createdAt"],
              );

              return Card(
                margin:
                    const EdgeInsets.only(
                        bottom: 20),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          15),
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
                                    customerEmail),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 15),
                      Text(
                        createdAt,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      Text(
                        "From: $senderNumber",
                        style:
                            const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "To: $receiverNumber",
                        style:
                            const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "Amount: \$$amount",
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "Status: $status",
                        style:
                            TextStyle(
                          fontSize: 16,
                          color: status ==
                                  "approved"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height: 15),
                      Row(
                        children: [
                          ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.green,
                            ),
                            onPressed: status ==
                                    "approved"
                                ? null
                                : () {
                                    approveExchange(
                                      exchangeId,
                                    );
                                  },
                            child:
                                const Text(
                              "Approve",
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
                              deleteExchange(
                                exchangeId,
                              );
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
      ),
    );
  }
}