import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'settings_screen.dart';
import 'order_history.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen> {

  String imageUrl = "";

  Future<void> uploadImage() async {

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if(picked == null) return;

    File file = File(picked.path);

    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("$userId.jpg");

    await ref.putFile(file);

    String url = await ref.getDownloadURL();

    setState(() {
      imageUrl = url;
    });

  }

  @override
  Widget build(BuildContext context) {

    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height:20),

            GestureDetector(

              onTap: (){
                uploadImage();
              },

              child: CircleAvatar(

                radius:50,

                backgroundImage:
                imageUrl != ""
                    ? NetworkImage(imageUrl)
                    : null,

                child: imageUrl == ""
                    ? const Icon(
                        Icons.person,
                        size:50,
                      )
                    : null,

              ),

            ),

            const SizedBox(height:20),

            Text(
              user?.email ?? "User",
              style: const TextStyle(
                fontSize:18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:10),

            const Text(
              "Customer Account",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height:30),

            const Divider(),

            ListTile(

              leading: const Icon(Icons.shopping_bag),

              title: const Text("My Orders"),

              onTap: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderHistory(),
                  ),
                );

              },

            ),

            ListTile(

              leading: const Icon(Icons.settings),

              title: const Text("Account Settings"),

              onTap: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );

              },

            ),

            const ListTile(
              leading: Icon(Icons.lock),
              title: Text("Security"),
            ),

          ],

        ),

      ),

    );

  }

}