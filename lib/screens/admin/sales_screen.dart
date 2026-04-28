import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          double totalSales = 0;
          double totalProfit = 0;
          double totalLoss = 0;

          for (var doc
              in snapshot.data!.docs) {
            final data =
                doc.data()
                    as Map<String, dynamic>;

            final total =
                (data["total"] ?? 0)
                    .toDouble();

            final status =
                data["status"] ??
                    "pending";

            totalSales += total;

            if (status ==
                "delivered") {
              totalProfit += total;
            }

            if (status ==
                "cancelled") {
              totalLoss += total;
            }
          }

          return Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text(
                        "Total Sales"),
                    trailing: Text(
                        "\$${totalSales.toStringAsFixed(2)}"),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text(
                        "Profit"),
                    trailing: Text(
                        "\$${totalProfit.toStringAsFixed(2)}"),
                  ),
                ),
                Card(
                  child: ListTile(
                    title:
                        const Text("Loss"),
                    trailing: Text(
                        "\$${totalLoss.toStringAsFixed(2)}"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}