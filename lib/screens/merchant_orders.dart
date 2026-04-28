import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantOrders extends StatelessWidget {

  final String merchantId;

  const MerchantOrders({
    super.key,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Orders"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("merchantId", isEqualTo: merchantId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text("No orders yet"),
            );
          }

          return ListView.builder(

            itemCount: orders.length,

            itemBuilder: (context, index) {

              var order = orders[index];

              Map<String, dynamic> data =
                  order.data() as Map<String, dynamic>;

              double total =
                  (data["total"] ?? 0).toDouble();

              double delivery =
                  (data["deliveryFee"] ?? 0).toDouble();

              String status =
                  data["status"] ?? "pending";

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text("Total: \$${total}"),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Delivery: \$${delivery}"),
                      Text("Status: $status"),

                    ],
                  ),

                  trailing: ElevatedButton(

                    onPressed: () async {

                      await order.reference.update({
                        "status": "approved"
                      });

                    },

                    child: const Text("Approve"),

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