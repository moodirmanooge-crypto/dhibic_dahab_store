import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {

  final String productId;

  const ReviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  final commentController = TextEditingController();

  int rating = 5;

  Future<void> submitReview() async {

    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("reviews")
        .add({

      "productId":widget.productId,
      "userId":userId,
      "rating":rating,
      "comment":commentController.text,
      "createdAt":Timestamp.now()

    });

    commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:Text("Review submitted"),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Write Review"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children:[

            DropdownButton<int>(

              value: rating,

              items: const [

                DropdownMenuItem(value:1,child:Text("⭐")),
                DropdownMenuItem(value:2,child:Text("⭐⭐")),
                DropdownMenuItem(value:3,child:Text("⭐⭐⭐")),
                DropdownMenuItem(value:4,child:Text("⭐⭐⭐⭐")),
                DropdownMenuItem(value:5,child:Text("⭐⭐⭐⭐⭐")),

              ],

              onChanged:(value){
                setState(() {
                  rating=value!;
                });
              },

            ),

            TextField(
              controller:commentController,
              decoration: const InputDecoration(
                labelText:"Comment",
              ),
            ),

            const SizedBox(height:20),

            ElevatedButton(

              onPressed: submitReview,

              child: const Text("Submit"),

            )

          ],

        ),

      ),

    );

  }

}