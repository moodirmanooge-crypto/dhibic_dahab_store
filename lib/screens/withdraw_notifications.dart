import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawNotifications extends StatelessWidget {

  const WithdrawNotifications({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Withdraw Requests"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("withdraw_requests")
            .snapshots(),

        builder:(context,snapshot){

          if(!snapshot.hasData){
            return const Center(
              child:CircularProgressIndicator(),
            );
          }

          var requests = snapshot.data!.docs;

          if(requests.isEmpty){
            return const Center(
              child: Text("No withdraw requests"),
            );
          }

          return ListView.builder(

            itemCount: requests.length,

            itemBuilder:(context,index){

              var r = requests[index];

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text(
                    "Amount: \$${r["amount"]}",
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Phone: ${r["phone"]}"),
                      Text("Status: ${r["status"]}")

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