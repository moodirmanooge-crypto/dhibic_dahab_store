import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Chats"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .orderBy(
              "lastMessageTime",
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()
                  as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.store),
                ),
                title: Text(
                  "${data["merchantName"]} chatting here",
                ),
                subtitle: Text(
                  data["lastMessage"] ?? "",
                ),
                trailing: data["customerSeen"] == true
                    ? const Icon(
                        Icons.done_all,
                        color: Colors.blue,
                      )
                    : const Icon(Icons.check),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: docs[index].id,
                        merchantName:
                            data["merchantName"],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}