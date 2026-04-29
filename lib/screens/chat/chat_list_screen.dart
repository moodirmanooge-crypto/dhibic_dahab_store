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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Weli ma jiraan sheekooyin (Chats)"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD4AF37),
                  child: Icon(Icons.store, color: Colors.white),
                ),
                title: Text(
                  "${data["merchantName"] ?? "Merchant"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data["lastMessage"] ?? "No messages yet",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: data["customerSeen"] == true
                    ? const Icon(Icons.done_all, color: Colors.blue)
                    : const Icon(Icons.check),
                onTap: () {
                  // ✅ Navigator-kan wuxuu u baahan yahay in ChatScreen uu xogtan aqbalo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: docs[index].id,
                        merchantName: data["merchantName"] ?? "Merchant",
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