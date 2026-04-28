import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import 'payment_screen.dart';

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
      final double price =
          double.tryParse(
                widget.book.price.toString(),
              ) ??
              0;

      /// FREE BOOK
      if (price <= 0) {
        setState(() {
          checking = false;
          isPurchased = true;
        });
        return;
      }

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          checking = false;
          isPurchased = false;
        });
        return;
      }

      final snap =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("purchased_books")
              .doc(widget.book.id)
              .get();

      setState(() {
        isPurchased = snap.exists;
        checking = false;
      });
    } catch (e) {
      setState(() {
        checking = false;
        isPurchased = false;
      });
    }
  }

  void openBook() {
    Navigator.pushNamed(
      context,
      "/pdf",
      arguments: widget.book.pdfUrl,
    );
  }

  Future<void> handleAction() async {
    final double price =
        double.tryParse(
              widget.book.price.toString(),
            ) ??
            0;

    /// FREE OR ALREADY PAID
    if (price <= 0 || isPurchased) {
      openBook();
      return;
    }

    /// GO TO PAYMENT
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          book: widget.book,
        ),
      ),
    );

    /// haddii payment success noqoto
    if (result == true) {
      await checkPurchase();

      if (isPurchased) {
        openBook(); // si automatic ah u fur
      }
    } else {
      await checkPurchase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double price =
        double.tryParse(
              widget.book.price.toString(),
            ) ??
            0;

    final bool isFree = price <= 0;

    if (checking) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.book.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(16),
              child: Image.network(
                widget.book.coverImage,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) {
                  return Container(
                    height: 230,
                    width: double.infinity,
                    alignment:
                        Alignment.center,
                    child: const Icon(
                      Icons.book,
                      size: 100,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.book.title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isFree
                  ? "FREE"
                  : isPurchased
                      ? "PAID ✅"
                      : "\$${price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: isFree ||
                        isPurchased
                    ? Colors.green
                    : Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: handleAction,
                child: Text(
                  isFree || isPurchased
                      ? "Read Book"
                      : "Buy / Pay",
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}