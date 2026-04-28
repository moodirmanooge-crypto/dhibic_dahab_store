import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details.dart';

class CategoryProducts extends StatelessWidget {

  final String category;

  const CategoryProducts({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(category),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("products")
            .where("category", isEqualTo: category)
            .snapshots(),

        builder:(context,snapshot){

          if(!snapshot.hasData){
            return const Center(
              child:CircularProgressIndicator(),
            );
          }

          var products = snapshot.data!.docs;

          if(products.isEmpty){
            return const Center(
              child:Text("No products"),
            );
          }

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

              return Card(

                elevation:3,

                child:Column(

                  children:[

                    Expanded(

                      child:data["image"] != ""
                          ? Image.network(
                        data["image"],
                        fit:BoxFit.cover,
                        width:double.infinity,
                      )
                          : const Icon(Icons.image,size:80),

                    ),

                    const SizedBox(height:5),

                    Text(
                      data["name"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("\$${data["price"]}")

                  ],

                ),

              );

            },

          );

        },

      ),

    );

  }

}