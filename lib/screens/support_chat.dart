import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportChat extends StatefulWidget {
  const SupportChat({super.key});

  @override
  State<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {

  final TextEditingController messageController =
      TextEditingController();

  final String userId =
      FirebaseAuth.instance.currentUser!.uid;

  void sendMessage() async {

    String text = messageController.text.trim();

    if(text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("support_chats")
        .doc(userId)
        .collection("messages")
        .add({

      "sender":"user",
      "text":text,
      "createdAt":Timestamp.now()

    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Support Chat"),
      ),

      body: Column(

        children: [

          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("support_chats")
                  .doc(userId)
                  .collection("messages")
                  .orderBy("createdAt")
                  .snapshots(),

              builder:(context,snapshot){

                if(!snapshot.hasData){
                  return const Center(
                    child:CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(

                  itemCount:messages.length,

                  itemBuilder:(context,index){

                    var data =
                        messages[index].data()
                        as Map<String,dynamic>;

                    bool isUser = data["sender"]=="user";

                    return Align(

                      alignment:
                      isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                      child:Container(

                        padding:const EdgeInsets.all(10),
                        margin:const EdgeInsets.all(8),

                        decoration:BoxDecoration(

                          color:isUser
                              ? Colors.blue
                              : Colors.grey[300],

                          borderRadius:
                          BorderRadius.circular(10),

                        ),

                        child:Text(
                          data["text"],
                          style:TextStyle(
                            color:isUser
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

          Row(

            children:[

              Expanded(

                child:TextField(
                  controller:messageController,
                  decoration:
                  const InputDecoration(
                    hintText:"Write message...",
                  ),
                ),

              ),

              IconButton(
                icon:const Icon(Icons.send),
                onPressed:sendMessage,
              )

            ],

          )

        ],

      ),

    );

  }

}