import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantProductsScreen extends StatelessWidget {

  final String merchantId;

  const MerchantProductsScreen({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("My Products")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where("merchantId", isEqualTo: merchantId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;

          return ListView.builder(

            itemCount: products.length,

            itemBuilder: (context, index) {

              var product = products[index];

              return ListTile(

                title: Text(product["name"]),

                subtitle: Text("\$${product["price"]}"),

                trailing: IconButton(
                  icon: const Icon(Icons.delete),

                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("products")
                        .doc(product.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}