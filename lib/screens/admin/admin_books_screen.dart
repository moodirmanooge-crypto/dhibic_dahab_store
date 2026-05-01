import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pdf_viewer_screen.dart';

class AdminBooksScreen extends StatelessWidget {
  const AdminBooksScreen({super.key});

  double parseDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text("All Books"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("books")
            .snapshots(),
        builder: (context, bookSnapshot) {
          if (!bookSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("purchases")
                .snapshots(),
            builder: (context, purchaseSnapshot) {
              if (!purchaseSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final books = bookSnapshot.data!.docs;
              final purchases = purchaseSnapshot.data!.docs;

              double totalRevenue = 0;

              for (var book in books) {
                final data = book.data() as Map<String, dynamic>;
                totalRevenue += parseDouble(data["price"]);
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Books: ${books.length}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Sold: ${purchases.length}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Revenue: \$${totalRevenue.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final doc = books[index];
                        final book = doc.data() as Map<String, dynamic>;

                        final title = book["title"] ?? "Unknown Book";
                        final image = book["image"] ?? "";
                        final price = parseDouble(book["price"]);
                        final pdfUrl = book["pdfUrl"] ?? "";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  image.isNotEmpty ? NetworkImage(image) : null,
                              child: image.isEmpty
                                  ? const Icon(Icons.book)
                                  : null,
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Price: \$${price.toStringAsFixed(2)}",
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(
                                    pdfUrl: pdfUrl,
                                    title: title,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}