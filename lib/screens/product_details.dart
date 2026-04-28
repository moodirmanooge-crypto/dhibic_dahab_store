import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'review_screen.dart';

class ProductDetails extends StatelessWidget {

  final String productId;
  final Map<String,dynamic> data;

  const ProductDetails({
    super.key,
    required this.productId,
    required this.data,
  });

  Future<void> addToCart(BuildContext context) async {

    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("cart")
        .doc(userId)
        .collection("items")
        .doc(productId)
        .set({

      "name": data["name"],
      "price": data["price"],
      "image": data["image"],
      "merchantId": data["merchantId"],
      "quantity": 1,

    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Product"),
      ),

      body: ListView(

        children: [

          /// PRODUCT IMAGE
          data["image"] != ""
              ? Image.network(
                  data["image"],
                  height: 250,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image,size:200),

          const SizedBox(height:20),

          /// PRODUCT NAME
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              data["name"],
              style: const TextStyle(
                fontSize:22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16),
            child: Text(
              "\$${data["price"]}",
              style: const TextStyle(fontSize:20),
            ),
          ),

          const SizedBox(height:20),

          /// ADD TO CART BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(

              onPressed: (){
                addToCart(context);
              },

              child: const Text("Add To Cart"),

            ),
          ),

          const SizedBox(height:20),

          /// WRITE REVIEW BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16),
            child: ElevatedButton(

              onPressed:(){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_)=>ReviewScreen(
                      productId: productId,
                    ),
                  ),
                );

              },

              child: const Text("Write Review"),

            ),
          ),

          const SizedBox(height:30),

          /// REVIEWS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal:16),
            child: Text(
              "Customer Reviews",
              style: TextStyle(
                fontSize:18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height:10),

          /// REVIEWS LIST
          StreamBuilder<QuerySnapshot>(

            stream: FirebaseFirestore.instance
                .collection("reviews")
                .where("productId", isEqualTo: productId)
                .snapshots(),

            builder:(context,snapshot){

              if(!snapshot.hasData){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              var reviews = snapshot.data!.docs;

              if(reviews.isEmpty){
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No reviews yet"),
                );
              }

              return ListView.builder(

                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: reviews.length,

                itemBuilder:(context,index){

                  var review = reviews[index];

                  Map<String,dynamic> r =
                  review.data() as Map<String,dynamic>;

                  return Card(

                    margin: const EdgeInsets.all(10),

                    child: ListTile(

                      title: Text(
                        "Rating: ${r["rating"]} ⭐",
                      ),

                      subtitle: Text(
                        r["comment"] ?? "",
                      ),

                    ),

                  );

                },

              );

            },

          ),

          const SizedBox(height:30),

        ],

      ),

    );
  }
}