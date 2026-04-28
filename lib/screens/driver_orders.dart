import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverOrders extends StatelessWidget {

  final String driverId;

  const DriverOrders({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Driver Orders"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("driverId", isEqualTo: driverId)
            .snapshots(),

        builder: (context,snapshot){

          if(!snapshot.hasData){
            return const Center(
              child:CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data!.docs;

          if(orders.isEmpty){
            return const Center(
              child:Text("No orders"),
            );
          }

          return ListView.builder(

            itemCount:orders.length,

            itemBuilder:(context,index){

              var order = orders[index];

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text("Total: \$${order["total"]}"),

                  subtitle: Text(
                    "Status: ${order["status"]}",
                  ),

                  trailing: ElevatedButton(

                    onPressed: () async {

                      await order.reference.update({
                        "status":"delivered"
                      });

                    },

                    child: const Text("Delivered"),

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