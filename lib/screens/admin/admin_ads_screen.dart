import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAdsScreen extends StatefulWidget {
  const AdminAdsScreen({super.key});

  @override
  State<AdminAdsScreen> createState() => _AdminAdsScreenState();
}

class _AdminAdsScreenState extends State<AdminAdsScreen> {
  final CollectionReference adsRef =
      FirebaseFirestore.instance.collection("ads");

  // 🗑️ DELETE AD
  Future<void> deleteAd(String id) async {
    await adsRef.doc(id).delete();

    // Hubi in widget-ku weli jiro ka hor intaanan isticmaalin context
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ad deleted successfully"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 🔥 CONFIRM DELETE
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Ad"),
          content: const Text("Are you sure you want to delete this ad?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteAd(id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // 👁️ VIEW IMAGE FULLSCREEN
  void showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text("All Ads"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: adsRef
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final ads = snapshot.data!.docs;

          if (ads.isEmpty) {
            return const Center(
              child: Text("No Ads Found"),
            );
          }

          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              final data = ad.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // 🖼️ IMAGE
                    GestureDetector(
                      onTap: () {
                        if (data["image"] != null) {
                          showImage(data["image"]);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data["image"] != null
                            ? Image.network(
                                data["image"],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey,
                                child: const Icon(Icons.image),
                              ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 📄 DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["title"] ?? "No Title",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data["description"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // 🗑️ DELETE
                    IconButton(
                      onPressed: () {
                        confirmDelete(ad.id);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}