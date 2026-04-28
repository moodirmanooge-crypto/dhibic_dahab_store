import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  String formatSomaliaTime(dynamic timestamp) {
    try {
      if (timestamp == null) return "Unknown time";

      final date = (timestamp as Timestamp).toDate();
      final somaliaTime =
          date.toUtc().add(const Duration(hours: 3));

      return DateFormat(
        "dd/MM/yyyy hh:mm a",
      ).format(somaliaTime);
    } catch (e) {
      return "Unknown time";
    }
  }

  String shortOrderNumber(int index) {
    return "#ORDER${index + 1}";
  }

  int calculatePoints(
      double amount,
      String type,
      ) {
    if (type == "exchange") {
      return (amount * 50).round();
    }

    if (type == "delivery") {
      return (amount * 30).round();
    }

    return (amount * 100).round();
  }

  Widget buildOrderCard({
    required Map<String, dynamic> data,
    required String type,
    required int index,
  }) {
    final total =
        (data["total"] ??
            data["amount"] ??
            data["deliveryFee"] ??
            0)
            .toDouble();

    final points =
    calculatePoints(total, type);

    final date =
    formatSomaliaTime(data["createdAt"]);

    final status =
        data["status"] ?? "pending";

    final image =
        data["image"] ??
            data["profileImage"] ??
            "";

    final title = type == "exchange"
        ? "Money Exchange"
        : type == "delivery"
        ? "Delivery Request"
        : data["productName"] ??
        "Unknown Product";

    final subtitle = type == "exchange"
        ? "${data["fromCompany"] ?? ""} → ${data["toCompany"] ?? ""}"
        : type == "delivery"
        ? data["customerLocation"] ??
        "Delivery"
        : data["merchantName"] ??
        "Store";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
              image,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) =>
                  Container(
                    width: 75,
                    height: 75,
                    color: Colors.grey[300],
                    child: const Icon(
                        Icons.image),
                  ),
            )
                : Container(
              width: 75,
              height: 75,
              color: Colors.grey[300],
              child: const Icon(
                  Icons.image),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  shortOrderNumber(index),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                Text(subtitle),
                Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                ),
                Text("Status: $status"),
                Text(
                  "Points earned: $points",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>>
  getAllOrders(String uid) {
    final ordersStream = FirebaseFirestore
        .instance
        .collection("orders")
        .where("customerId",
        isEqualTo: uid)
        .snapshots();

    final exchangeStream =
    FirebaseFirestore.instance
        .collection(
        "exchange_orders")
        .where(
      "customerEmail",
      isEqualTo: FirebaseAuth
          .instance
          .currentUser
          ?.email,
    )
        .snapshots();

    final deliveryStream =
    FirebaseFirestore.instance
        .collection(
        "driver_requests")
        .where("customerId",
        isEqualTo: uid)
        .snapshots();

    return Stream.periodic(
      const Duration(seconds: 1),
          (_) async {
        final orders =
        await ordersStream.first;
        final exchanges =
        await exchangeStream.first;
        final deliveries =
        await deliveryStream.first;

        List<Map<String, dynamic>>
        all = [];

        for (var doc in orders.docs) {
          final data = doc.data()
          as Map<String, dynamic>;
          data["type"] = "shop";
          all.add(data);
        }

        for (var doc
        in exchanges.docs) {
          final data = doc.data()
          as Map<String, dynamic>;
          data["type"] =
          "exchange";
          all.add(data);
        }

        for (var doc
        in deliveries.docs) {
          final data = doc.data()
          as Map<String, dynamic>;
          data["type"] =
          "delivery";
          all.add(data);
        }

        all.sort((a, b) {
          final ta =
          a["createdAt"]
          as Timestamp?;
          final tb =
          b["createdAt"]
          as Timestamp?;

          if (ta == null ||
              tb == null) {
            return 0;
          }

          return tb
              .toDate()
              .compareTo(
            ta.toDate(),
          );
        });

        return all;
      },
    ).asyncMap((event) => event);
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child:
          Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFFD4AF37),
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<
          List<Map<String, dynamic>>>(
        stream: getAllOrders(user.uid),
        builder:
            (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final allOrders =
              snapshot.data!;

          if (allOrders.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
            const EdgeInsets.all(
                12),
            itemCount:
            allOrders.length,
            itemBuilder:
                (context, index) {
              final data =
              allOrders[index];

              return buildOrderCard(
                data: data,
                type: data["type"],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}