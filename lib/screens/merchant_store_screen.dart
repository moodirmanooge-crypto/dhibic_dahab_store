import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantStoreScreen extends StatelessWidget {

  final String merchantId;

  const MerchantStoreScreen({
    super.key,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Store"),
      ),

      body: Column(

        children: [

          /// MERCHANT INFO
          StreamBuilder<DocumentSnapshot>(

            stream: FirebaseFirestore.instance
                .collection("merchant")
                .doc(merchantId)
                .snapshots(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              Map<String,dynamic> data =
                  snapshot.data!.data() as Map<String,dynamic>;

              String name = data["name"] ?? "";
              String image = data["image"] ?? "";

              return Column(

                children: [

                  const SizedBox(height:10),

                  CircleAvatar(
                    radius:40,
                    backgroundImage:
                        image != "" ? NetworkImage(image) : null,
                    child: image == ""
                        ? const Icon(Icons.store)
                        : null,
                  ),

                  const SizedBox(height:10),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize:20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height:20),

                ],

              );

            },

          ),

          /// PRODUCTS
          Expanded(

            child: StreamBuilder<QuerySnapshot>(

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

                return GridView.builder(

                  padding: const EdgeInsets.all(10),

                  itemCount: products.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:2,
                    childAspectRatio:0.75,
                  ),

                  itemBuilder:(context,index){

                    var doc = products[index];

                    Map<String,dynamic> data =
                        doc.data() as Map<String,dynamic>;

                    String name = data["name"] ?? "";
                    String price = data["price"].toString();
                    String image = data["image"] ?? "";

                    return Card(

                      child: Column(

                        children: [

                          Expanded(

                            child: image != ""
                                ? Image.network(
                                    image,
                                    fit:BoxFit.cover,
                                    width:double.infinity,
                                  )
                                : const Icon(Icons.image,size:80),

                          ),

                          const SizedBox(height:5),

                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight:FontWeight.bold,
                            ),
                          ),

                          Text("\$$price"),

                          const SizedBox(height:10),

                        ],

                      ),

                    );

                  },

                );

              },

            ),

          )

        ],

      ),

    );

  }

}