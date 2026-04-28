import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'merchant_chat_screen.dart';

class MerchantChatList extends StatelessWidget {
  final String merchantId;
  final String merchantName;

  const MerchantChatList({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text(
          "$merchantName Customer Chats",
        ),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body:
          StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection("chats")
            .where(
              "merchantId",
              isEqualTo: merchantId,
            )
            .orderBy(
              "lastMessageTime",
              descending: true,
            )
            .snapshots(),
        builder:
            (context, snapshot) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No chats for $merchantName yet",
                style:
                    const TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder:
                (context, index) {
              final data = docs[index]
                      .data()
                  as Map<String,
                      dynamic>;

              final customerName =
                  data["customerName"]
                          ?.toString() ??
                      "Customer";

              final lastMessage =
                  data["lastMessage"]
                          ?.toString() ??
                      "";

              final seen =
                  data["merchantSeen"] ==
                      true;

              return Card(
                margin:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading:
                      const CircleAvatar(
                    child: Icon(
                        Icons.person),
                  ),
                  title: Text(
                    customerName,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  subtitle:
                      Text(lastMessage),
                  trailing: Icon(
                    seen
                        ? Icons.done_all
                        : Icons.check,
                    color: seen
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MerchantChatScreen(
                          chatId:
                              docs[index]
                                  .id,
                          customerName:
                              customerName,
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