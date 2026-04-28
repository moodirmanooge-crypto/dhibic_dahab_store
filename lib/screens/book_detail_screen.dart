import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'payment_screen.dart';

class BookDetailScreen extends StatelessWidget {

  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Column(
        children: [

          Image.network(book.coverImage),

          Text(book.title,
              style: const TextStyle(fontSize: 22)),

          Text("\$${book.price}"),

          ElevatedButton(
            child: const Text("Buy / Pay"),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(book: book),
                ),
              );

            },
          )
        ],
      ),
    );
  }
}