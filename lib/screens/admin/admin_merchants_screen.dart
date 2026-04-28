import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMerchantsScreen extends StatelessWidget {
  const AdminMerchantsScreen({super.key});

  double parseDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(
            value.toString()) ??
        0;
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(
            value.toString()) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        title:
            const Text("All Merchants"),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("merchant")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                  "Error loading merchants"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final merchants =
              snapshot.data!.docs
                  .map((e) => e.data()
                      as Map<String, dynamic>)
                  .toList();

          merchants.sort((a, b) {
            final salesA =
                parseInt(a["salesCount"]);
            final salesB =
                parseInt(b["salesCount"]);

            final reviewA =
                parseDouble(
                    a["rating"]);
            final reviewB =
                parseDouble(
                    b["rating"]);

            final scoreA =
                salesA + reviewA;
            final scoreB =
                salesB + reviewB;

            return scoreB.compareTo(
                scoreA);
          });

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.all(
                        15),
                padding:
                    const EdgeInsets.all(
                        16),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Text(
                  "Total Merchants: ${merchants.length}",
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child:
                    ListView.builder(
                  itemCount:
                      merchants.length,
                  itemBuilder:
                      (context, index) {
                    final merchant =
                        merchants[
                            index];

                    final name =
                        merchant["storeName"] ??
                            merchant[
                                "name"] ??
                            "Unknown Store";

                    final email =
                        merchant["email"] ??
                            "No email";

                    final password =
                        merchant["password"] ??
                            "Hidden";

                    final logo =
                        merchant["logo"] ??
                            merchant[
                                "image"] ??
                            "";

                    final rating =
                        parseDouble(
                            merchant[
                                "rating"]);

                    final totalReviews =
                        parseInt(merchant[
                            "reviewCount"]);

                    final sales =
                        parseInt(merchant[
                            "salesCount"]);

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal:
                            15,
                        vertical: 8,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(
                                15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  logo.isNotEmpty
                                      ? NetworkImage(
                                          logo)
                                      : null,
                              child: logo
                                      .isEmpty
                                  ? const Icon(
                                      Icons
                                          .store)
                                  : null,
                            ),
                            const SizedBox(
                                width:
                                    12),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          18,
                                    ),
                                  ),
                                  Text(
                                      email),
                                  Text(
                                      "Password: $password"),
                                  Text(
                                      "⭐ $rating"),
                                  Text(
                                      "Reviews: $totalReviews"),
                                  Text(
                                      "Sales: $sales"),
                                ],
                              ),
                            ),
                            Text(
                              "#${index + 1}",
                              style:
                                  const TextStyle(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}