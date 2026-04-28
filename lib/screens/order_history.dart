import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistory extends StatelessWidget {

  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {

    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Orders"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: userId)
            .snapshots(),

        builder:(context,snapshot){

          if(!snapshot.hasData){
            return const Center(
              child:CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data!.docs;

          if(orders.isEmpty){
            return const Center(
              child: Text("No orders yet"),
            );
          }

          return ListView.builder(

            itemCount: orders.length,

            itemBuilder:(context,index){

              var order = orders[index];

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text(
                    "Total: \$${order["total"]}",
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Delivery: \$${order["deliveryFee"]}",
                      ),

                      Text(
                        "Status: ${order["status"]}",
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