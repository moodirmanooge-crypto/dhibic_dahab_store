import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("books").snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No books available"));
          }

          var books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {

              var doc = books[index];
              var book = doc.data() as Map<String, dynamic>;

              String title = book["title"] ?? "No title";
              double price = (book["price"] ?? 0).toDouble();
              String image = book["coverImage"] ??
                  "https://via.placeholder.com/150";
              String pdfUrl = book["pdfUrl"] ?? "";

              return Card(
                child: ListTile(

                  leading: Image.network(
                    image,
                    width: 50,
                    errorBuilder: (a,b,c){
                      return const Icon(Icons.menu_book);
                    },
                  ),

                  title: Text(title),

                  subtitle: Text("\$$price"),

                  trailing: const Icon(Icons.shopping_cart),

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          bookId: doc.id,
                          price: price,
                          pdfUrl: pdfUrl,
                        ),
                      ),
                    );

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