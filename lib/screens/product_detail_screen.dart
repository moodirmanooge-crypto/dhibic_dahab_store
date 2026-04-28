import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatelessWidget {

  final String productId;
  final Map product;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  Future buyProduct() async {

    double price = product["price"];
    String merchantId = product["merchantId"];

    double commission = price * 0.10;
    double merchantProfit = price - commission;

    await FirebaseFirestore.instance.collection("orders").add({

      "productId": productId,
      "productName": product["name"],
      "price": price,
      "merchantId": merchantId,
      "commission": commission,
      "merchantProfit": merchantProfit,
      "status": "paid",
      "createdAt": Timestamp.now(),

    });

    await FirebaseFirestore.instance
        .collection("merchant")
        .doc(merchantId)
        .update({

      "wallet": FieldValue.increment(merchantProfit)

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(product["name"]),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Image.network(
              product["image"],
              height: 220,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            Text(
              product["name"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "\$${product["price"]}",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),

            Text(product["description"]),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  await buyProduct();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order successful"),
                    ),
                  );

                },

                child: const Text("Buy Now"),

              ),
            )

          ],

        ),
      ),
    );
  }
}