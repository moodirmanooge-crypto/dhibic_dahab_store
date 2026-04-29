import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoPopupWidget extends StatefulWidget {
  const PromoPopupWidget({super.key});

  @override
  State<PromoPopupWidget> createState() => _PromoPopupWidgetState();
}

class _PromoPopupWidgetState extends State<PromoPopupWidget> {
  bool isClosed = false;

  @override
  Widget build(BuildContext context) {
    if (isClosed) {
      return const SizedBox();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("promo_ads")
          .where("isActive", isEqualTo: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        // 🔥 Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        // 🔥 Error safe
        if (snapshot.hasError) {
          return const SizedBox();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final data =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;

        final image = data["image"]?.toString() ?? "";

        if (image.isEmpty) {
          return const SizedBox();
        }

        return Container(
          color: Colors.black54,
          child: Center(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      // 🔥 CRASH FIX (image fail)
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(height: 200),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ❌ CLOSE BUTTON
                Positioned(
                  top: 8,
                  right: 28,
                  child: GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      setState(() {
                        isClosed = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}