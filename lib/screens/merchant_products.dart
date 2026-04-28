import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantProducts extends StatelessWidget {

  final String merchantId;

  const MerchantProducts({
    super.key,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Products"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("products")
            .where("merchantId", isEqualTo: merchantId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text("No products"),
            );
          }

          return ListView.builder(

            itemCount: products.length,

            itemBuilder: (context, index) {

              var doc = products[index];

              Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;

              String name = data["name"] ?? "";
              String price = data["price"].toString();
              String image = data["image"] ?? "";

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: image != ""
                      ? Image.network(
                          image,
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),

                  title: Text(name),

                  subtitle: Text("\$$price"),

                  trailing: IconButton(

                    icon: const Icon(Icons.delete),

                    onPressed: () async {

                      await doc.reference.delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Product removed"),
                        ),
                      );

                    },

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