import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'book_detail_screen.dart';

class ReadingBooks extends StatelessWidget {
  final String category;
  final String search;

  const ReadingBooks({
    super.key,
    required this.category,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    Query query =
        FirebaseFirestore.instance
            .collection("books");

    if (category != "all") {
      query = query.where(
        "category",
        isEqualTo: category,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        var books =
            snapshot.data!.docs;

        var filteredBooks =
            books.where((doc) {
          final raw =
              doc.data()
                  as Map<String, dynamic>;

          final title =
              (raw["title"] ?? "")
                  .toString()
                  .toLowerCase();

          return title.contains(
            search.toLowerCase(),
          );
        }).toList();

        if (filteredBooks.isEmpty) {
          return const Center(
            child:
                Text("No books found"),
          );
        }

        return ListView.builder(
          itemCount:
              filteredBooks.length,
          itemBuilder:
              (context, index) {
            final doc =
                filteredBooks[index];

            final data =
                doc.data()
                    as Map<String, dynamic>;

            final book =
                Book.fromFirestore(
              doc.id,
              data,
            );

            return Card(
              child: ListTile(
                leading:
                    Image.network(
                  book.coverImage,
                  width: 50,
                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.menu_book,
                    );
                  },
                ),
                title: Text(
                    book.title),
                subtitle: Text(
                  book.price <= 0
                      ? "FREE"
                      : "\$${book.price}",
                ),
                trailing:
                    const Icon(
                  Icons
                      .picture_as_pdf,
                ),

                /// 🔥 FIXED HERE
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
    );
  }
}