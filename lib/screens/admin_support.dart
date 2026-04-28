import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSupport extends StatelessWidget {

  const AdminSupport({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Support Chats"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("support_chats")
            .snapshots(),

        builder:(context,snapshot){

          if(!snapshot.hasData){
            return const Center(
              child:CircularProgressIndicator(),
            );
          }

          var chats = snapshot.data!.docs;

          return ListView.builder(

            itemCount: chats.length,

            itemBuilder:(context,index){

              var chat = chats[index];

              return ListTile(

                title: Text("User: ${chat.id}"),

                onTap:(){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(_)=>AdminChatScreen(
                        chatId: chat.id,
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