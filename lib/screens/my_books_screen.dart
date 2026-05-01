import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pdf_viewer_screen.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    print("🔥 USER UID = ${user?.uid}");
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ❌ USER NOT LOGGED
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first")),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Books"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("purchased_books")
            .where("userId", isEqualTo: userId)
            // ❗ TEMP: orderBy removed (index error ka hortag)
            .snapshots(),

        builder: (context, snapshot) {

          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            print("🔥 FIRESTORE ERROR: ${snapshot.error}");
            return const Center(child: Text("Error loading books"));
          }

          // 📭 EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("⚠️ No books found for this user");
            return const Center(child: Text("No books yet"));
          }

          final books = snapshot.data!.docs;

          print("✅ BOOKS FOUND: ${books.length}");

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {

              final data =
                  books[index].data() as Map<String, dynamic>;

              final ts = data["createdAt"] as Timestamp?;
              final date = ts?.toDate();

              final image = data["image"] ?? "";
              final name = data["name"] ?? "Unknown Book";
              final pdfUrl = data["pdfUrl"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(

                  leading: image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            image,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.book),
                          ),
                        )
                      : const Icon(Icons.book),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    date != null
                        ? "Bought: ${date.day}/${date.month}/${date.year}"
                        : "",
                  ),

                  trailing: const Icon(Icons.menu_book),

                  onTap: () {
                    if (pdfUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("PDF not found"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          pdfUrl: pdfUrl,
                          title: name,
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