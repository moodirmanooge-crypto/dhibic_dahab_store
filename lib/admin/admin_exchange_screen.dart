import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminExchangeScreen extends StatelessWidget {
  const AdminExchangeScreen({super.key});

  String formatSomaliaTime(dynamic timestamp) {
    if (timestamp == null) return "Unknown";

    final date =
        (timestamp as Timestamp).toDate();

    final somaliaTime =
        date.toUtc().add(
      const Duration(hours: 3),
    );

    return DateFormat(
      "dd/MM/yyyy hh:mm a",
    ).format(somaliaTime);
  }

  Future<void> approveExchange(
      String id) async {
    await FirebaseFirestore.instance
        .collection("exchange_orders")
        .doc(id)
        .update({
      "status": "approved",
      "approvedAt":
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExchange(
      String id) async {
    await FirebaseFirestore.instance
        .collection("exchange_orders")
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text(
            "All Exchange Money"),
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
                "No exchange orders yet",
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder:
                (context, index) {
              final doc = orders[index];

              final data = doc.data()
                  as Map<String, dynamic>;

              final email =
                  data["customerEmail"] ??
                      "No email";

              final image =
                  data["profileImage"] ??
                      "";

              final sender =
                  data["senderNumber"] ??
                      "";

              final receiver =
                  data["receiverNumber"] ??
                      "";

              final from =
                  data["fromCompany"] ??
                      "";

              final to =
                  data["toCompany"] ?? "";

              final amount =
                  data["amount"] ?? 0;

              final finalAmount =
                  data["finalAmount"] ??
                      0;

              final status =
                  data["status"] ??
                      "pending";

              final time =
                  formatSomaliaTime(
                data["createdAt"],
              );

              return Card(
                margin:
                    const EdgeInsets.only(
                        bottom: 18),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          16),
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
                                image
                                        .isNotEmpty
                                    ? NetworkImage(
                                        image)
                                    : null,
                            child:
                                image.isEmpty
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
                                Text(
                                  email,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        17,
                                  ),
                                ),
                                Text(time),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                          height: 25),
                      Text("From: $from"),
                      Text("To: $to"),
                      Text(
                          "Sender: $sender"),
                      Text(
                          "Receiver: $receiver"),
                      Text(
                          "Amount: \$$amount"),
                      Text(
                          "Final: \$$finalAmount"),
                      Text(
                        "Status: $status",
                        style: TextStyle(
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
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              approveExchange(
                                  doc.id);
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.green,
                            ),
                            child:
                                const Text(
                                    "Approve"),
                          ),
                          const SizedBox(
                              width: 10),
                          ElevatedButton(
                            onPressed: () {
                              deleteExchange(
                                  doc.id);
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.red,
                            ),
                            child:
                                const Text(
                                    "Delete"),
                          ),
                        ],
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