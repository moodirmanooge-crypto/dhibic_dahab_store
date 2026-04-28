import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String merchantName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.merchantName,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final controller = TextEditingController();

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final text = controller.text.trim();

    controller.clear();

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
      "sender": "customer",
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
      "merchantSeen": false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.merchantName} chatting here",
        ),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(widget.chatId)
                  .collection("messages")
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final docs =
                    snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data()
                            as Map<String,
                                dynamic>;

                    final isMe =
                        data["sender"] ==
                            "customer";

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
                        decoration:
                            BoxDecoration(
                          color: isMe
                              ? Colors
                                  .green
                              : Colors
                                  .grey
                                  .shade300,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Text(
                              data["message"],
                              style:
                                  TextStyle(
                                color: isMe
                                    ? Colors
                                        .white
                                    : Colors
                                        .black,
                              ),
                            ),
                            const SizedBox(
                                width: 6),
                            if (isMe)
                              Icon(
                                data["seen"] ==
                                        true
                                    ? Icons
                                        .done_all
                                    : Icons
                                        .check,
                                size: 18,
                                color: data["seen"] ==
                                        true
                                    ? Colors
                                        .blue
                                    : Colors
                                        .white,
                              )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        controller,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Write message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                      Icons.send),
                  onPressed:
                      sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}