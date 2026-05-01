import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'book_detail_screen.dart';
import 'my_books_screen.dart'; // Hubi in magaca file-kan uu sax yahay

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBooksScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("books")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final doc = books[index];

              final data =
                  doc.data() as Map<String, dynamic>;

              final book = Book.fromFirestore(
                doc.id,
                data,
              );

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    book.coverImage,
                    width: 50,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.book);
                    },
                  ),
                  title: Text(book.title),
                  subtitle: Text(
                    book.price <= 0
                        ? "FREE"
                        : "\$${book.price}",
                  ),
                  trailing: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookDetailScreen(
                          book: book,
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