import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/cart_screen.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {

    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("cart")
          .doc(userId)
          .collection("items")
          .snapshots(),

      builder: (context, snapshot) {

        int count = 0;

        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

        return Stack(

          children: [

            IconButton(

              icon: const Icon(Icons.shopping_cart),

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );

              },

            ),

            if (count > 0)

              Positioned(
                right: 6,
                top: 6,
                child: Container(

                  padding: const EdgeInsets.all(4),

                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),

                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),

                ),
              )

          ],

        );

      },

    );
  }
}