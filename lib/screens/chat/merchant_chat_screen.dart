import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../service/notification_service.dart';

class MerchantChatScreen extends StatefulWidget {
  final String chatId;
  final String customerName;

  const MerchantChatScreen({
    super.key,
    required this.chatId,
    required this.customerName,
  });

  @override
  State<MerchantChatScreen> createState() =>
      _MerchantChatScreenState();
}

class _MerchantChatScreenState
    extends State<MerchantChatScreen> {
  final TextEditingController controller =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
      "sender": "merchant",
      "message": text,
      "seen": false,
      "createdAt":
          FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .update({
      "lastMessage": text,
      "lastMessageTime":
          FieldValue.serverTimestamp(),
      "customerSeen": false,
      "merchantSeen": true,
    });

    /// 🔥 CUSTOMER POPUP
    await NotificationService.showNotification(
      title: "Reply from Seller",
      body: text,
    );

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController
                .position.maxScrollExtent,
            duration: const Duration(
                milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text(widget.customerName),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection("chats")
                  .doc(widget.chatId)
                  .collection("messages")
                  .orderBy("createdAt")
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data!.docs;

                WidgetsBinding.instance
                    .addPostFrameCallback(
                  (_) => scrollToBottom(),
                );

                return ListView.builder(
                  controller:
                      scrollController,
                  itemCount: docs.length,
                  itemBuilder:
                      (context, index) {
                    final data = docs[index]
                            .data()
                        as Map<String,
                            dynamic>;

                    final isMe =
                        data["sender"] ==
                            "merchant";

                    return Align(
                      alignment: isMe
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets
                                .all(8),
                        padding:
                            const EdgeInsets
                                .all(12),
                        constraints:
                            const BoxConstraints(
                          maxWidth: 280,
                        ),
                        decoration:
                            BoxDecoration(
                          color: isMe
                              ? Colors.green
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          data["message"] ??
                              "",
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding:
                const EdgeInsets.all(8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Reply message...",
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.send),
                    onPressed:
                        sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}