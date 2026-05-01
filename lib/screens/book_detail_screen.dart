import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import 'payment_screen.dart';
import 'pdf_viewer_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() =>
      _BookDetailScreenState();
}

class _BookDetailScreenState
    extends State<BookDetailScreen> {
  bool isPurchased = false;
  bool checking = true;

  @override
  void initState() {
    super.initState();
    checkPurchase();
  }

  Future<void> checkPurchase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          checking = false;
          isPurchased = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection("purchased_books")
          .where("userId", isEqualTo: user.uid)
          .where("pdfUrl", isEqualTo: widget.book.pdfUrl)
          .get();

      setState(() {
        isPurchased = snap.docs.isNotEmpty;
        checking = false;
      });
    } catch (e) {
      setState(() {
        checking = false;
        isPurchased = false;
      });
    }
  }

  Future<void> handleAction() async {
    final price =
        double.tryParse(widget.book.price.toString()) ?? 0;

    // FREE or already purchased
    if (price <= 0 || isPurchased) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            pdfUrl: widget.book.pdfUrl,
            title: widget.book.title,
          ),
        ),
      );
      return;
    }

    // PAYMENT
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(book: widget.book),
      ),
    );

    if (result == true) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("purchased_books")
            .add({
          "userId": user.uid,
          "name": widget.book.title,
          "image": widget.book.coverImage,
          "pdfUrl": widget.book.pdfUrl, // ✅ FIXED
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            pdfUrl: widget.book.pdfUrl,
            title: widget.book.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final price =
        double.tryParse(widget.book.price.toString()) ?? 0;

    if (checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(widget.book.coverImage, height: 200),
            const SizedBox(height: 20),
            Text(widget.book.title,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(
              price <= 0
                  ? "FREE"
                  : isPurchased
                      ? "PAID ✅"
                      : "\$${price.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleAction,
              child: Text(
                price <= 0 || isPurchased
                    ? "Read Book"
                    : "Buy Book",
              ),
            )
          ],
        ),
      ),
    );
  }
}