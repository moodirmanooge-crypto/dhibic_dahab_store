import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrders extends StatelessWidget {

  const CustomerOrders({super.key});

  @override
  Widget build(BuildContext context) {

    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Orders"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: userId)
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
              child: Text("No orders"),
            );
          }

          return ListView.builder(

            itemCount: orders.length,

            itemBuilder:(context,index){

              var order = orders[index];

              Map<String,dynamic> data =
                  order.data() as Map<String,dynamic>;

              double total =
                  (data["total"] ?? 0).toDouble();

              String status =
                  data["status"] ?? "pending";

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text("Total: \$${total}"),

                  subtitle: Text("Status: $status"),

                ),

              );

            },

          );

        },

      ),

    );

  }

}