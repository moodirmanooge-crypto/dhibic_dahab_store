import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details.dart';
import 'merchant_store_screen.dart';

class HomeProducts extends StatelessWidget {
  const HomeProducts({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("products")
          .snapshots(),

      builder: (context,snapshot){

        if(!snapshot.hasData){
          return const Center(
            child:CircularProgressIndicator(),
          );
        }

        var products = snapshot.data!.docs;

        return GridView.builder(

          padding: const EdgeInsets.all(10),

          itemCount: products.length,

          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:2,
              childAspectRatio:0.72
          ),

          itemBuilder:(context,index){

            var doc = products[index];

            Map<String,dynamic> data =
            doc.data() as Map<String,dynamic>;

            /// FIX 🔴 merchantId empty error
            String merchantId = data["merchantId"] ?? "";

            if(merchantId.isEmpty){
              return const SizedBox();
            }

            return FutureBuilder<DocumentSnapshot>(

              future: FirebaseFirestore.instance
                  .collection("merchant")
                  .doc(merchantId)
                  .get(),

              builder:(context,merchantSnap){

                String merchantName = "";
                String merchantImage = "";

                if(merchantSnap.hasData && merchantSnap.data!.exists){

                  Map<String,dynamic> m =
                  merchantSnap.data!.data() as Map<String,dynamic>;

                  merchantName = m["name"] ?? "";
                  merchantImage = m["image"] ?? "";

                }

                return Card(

                  elevation:3,

                  child:Column(

                    children:[

                      /// PRODUCT IMAGE
                      Expanded(

                        child:GestureDetector(

                          onTap:(){

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:(_)=>ProductDetails(
                                  productId: doc.id,
                                  data: data,
                                ),
                              ),
                            );

                          },

                          child:(data["image"] ?? "") != ""
                              ? Image.network(
                            data["image"],
                            fit:BoxFit.cover,
                            width:double.infinity,
                          )
                              : const Icon(Icons.image,size:80),

                        ),

                      ),

                      const SizedBox(height:5),

                      /// PRODUCT NAME
                      Text(
                        data["name"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// PRICE
                      Text("\$${data["price"] ?? ""}"),

                      const SizedBox(height:5),

                      /// MERCHANT ROW
                      GestureDetector(

                        onTap:(){

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_)=>MerchantStoreScreen(
                                merchantId: merchantId,
                              ),
                            ),
                          );

                        },

                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[

                            CircleAvatar(
                              radius:10,
                              backgroundImage:
                              merchantImage != ""
                                  ? NetworkImage(merchantImage)
                                  : null,
                              child: merchantImage == ""
                                  ? const Icon(Icons.store,size:12)
                                  : null,
                            ),

                            const SizedBox(width:5),

                            Text(
                              merchantName,
                              style: const TextStyle(
                                fontSize:12,
                                fontWeight: FontWeight.w500,
                              ),
                            )

                          ],
                        ),

                      ),

                      const SizedBox(height:5),

                    ],

                  ),

                );

              },

            );

          },

        );

      },

    );

  }

}