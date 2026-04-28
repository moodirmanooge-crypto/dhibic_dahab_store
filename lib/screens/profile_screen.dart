import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'delivery/delivery_request_screen.dart';
import 'login_screen.dart';
import 'order_history.dart';

class ProfileScreen extends StatefulWidget {
  final String currentLang;

  const ProfileScreen({
    super.key,
    this.currentLang = "en",
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  File? selectedImage;
  final picker = ImagePicker();

  final String databaseUrl =
      "https://dhibic-dahab-online-store-default-rtdb.europe-west1.firebasedatabase.app/";

  String get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ??
      "guest";

  String get currentEmail =>
      FirebaseAuth.instance.currentUser?.email ??
      "No email";

  String? imagePath;

  Future<void> createUserIfNotExists() async {
    final ref =
        FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref("users/$currentUserId");

    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        "name": currentEmail.split("@").first,
        "email": currentEmail,
        "shoppingPoints": 0,
        "deliveryPoints": 0,
        "profileImage": "",
      });
    }
  }

  // 🔥 UPDATED (FIREBASE STORAGE)
  Future<void> pickImage() async {
    final picked =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      final file = File(picked.path);

      setState(() {
        selectedImage = file;
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("$currentUserId.jpg");

      await ref.putFile(file);

      final downloadUrl =
          await ref.getDownloadURL();

      await FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      )
          .ref("users/$currentUserId/profileImage")
          .set(downloadUrl);
    }
  }

  Future<void> editName(
      String oldName) async {
    final controller =
        TextEditingController(
      text: oldName,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseDatabase
                  .instanceFor(
                app: Firebase.app(),
                databaseURL:
                    databaseUrl,
              )
                  .ref(
                      "users/$currentUserId/name")
                  .set(
                      controller.text);

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> openWhatsApp() async {
    final uri = Uri.parse(
        "https://wa.me/252617753787");

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> openEmail() async {
    final uri = Uri(
      scheme: "mailto",
      path: "dhibicdahabstore@gmail.com",
    );

    await launchUrl(uri);
  }

  Future<void> openPhone() async {
    final uri = Uri(
      scheme: "tel",
      path: "617753787",
    );

    await launchUrl(uri);
  }

  void showHelpDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.chat,
                color: Colors.green,
              ),
              title:
                  const Text("Chat WhatsApp"),
              onTap: openWhatsApp,
            ),
            ListTile(
              leading: const Icon(
                Icons.email,
                color: Colors.red,
              ),
              title: const Text("Email"),
              onTap: openEmail,
            ),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: Colors.blue,
              ),
              title: const Text("Call"),
              onTap: openPhone,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logoutUser() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance
        .signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    createUserIfNotExists();
  }

  Widget menuTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(
                bottom: 18),
        padding:
            const EdgeInsets.all(
                18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
                  22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 34,
              color: iconColor,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ),
            const Icon(
              Icons
                  .keyboard_arrow_right,
              size: 30,
              color: Colors.amber,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    final langProvider =
        Provider.of<
            LanguageProvider>(
      context,
    );

    final themeProvider =
        Provider.of<
            ThemeProvider>(
      context,
    );

    final userRef =
        FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref("users/$currentUserId");

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F2EC),
      body: StreamBuilder(
        stream: userRef.onValue,
        builder:
            (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot
                      .data!
                      .snapshot
                      .value ==
                  null) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final userData =
              Map<String,
                  dynamic>.from(
            snapshot.data!
                .snapshot.value as Map,
          );

          final name =
              userData["name"] ??
                  "User";

          final savedImage =
              userData[
                      "profileImage"] ??
                  "";

          final shoppingPoints =
              userData[
                      "shoppingPoints"] ??
                  0;

          final deliveryPoints =
              userData[
                      "deliveryPoints"] ??
                  0;

          return SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .all(20),
              child: Column(
                children: [
                  const SizedBox(
                      height: 20),
                  GestureDetector(
                    onTap: pickImage,
                    onLongPress: () =>
                        editName(name),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor:
                          const Color(
                              0xFFD4AF37),
                      backgroundImage:
                          savedImage
                                  .toString()
                                  .isNotEmpty
                              ? NetworkImage(
                                  savedImage)
                              : null,
                      child: savedImage
                              .toString()
                              .isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors
                                  .white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(
                      height: 18),
                  GestureDetector(
                    onTap: () =>
                        editName(name),
                    child: Text(
                      name,
                      style:
                          const TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 6),
                  Text(
                    currentEmail,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      color:
                          Colors.grey,
                    ),
                  ),
                  const SizedBox(
                      height: 30),

                  menuTile(
                    icon:
                        Icons.shopping_bag,
                    title:
                        "My Orders",
                    iconColor:
                        Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OrderHistory(),
                        ),
                      );
                    },
                  ),

                  menuTile(
                    icon: Icons.help,
                    title: "Help Me",
                    iconColor:
                        Colors.blue,
                    onTap: showHelpDialog,
                  ),

                  menuTile(
                    icon: Icons.settings,
                    title: "Settings",
                    iconColor:
                        Colors.amber,
                    onTap: () {
                      _showSettingsDialog(
                        context,
                        langProvider,
                        themeProvider,
                      );
                    },
                  ),

                  menuTile(
                    icon: Icons.logout,
                    title: "Logout",
                    iconColor:
                        Colors.red,
                    onTap:
                        logoutUser,
                  ),

                  const SizedBox(
                      height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _pointsCard(
                          "Shopping",
                          shoppingPoints
                              .toString(),
                          const Color(
                              0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(
                          width: 12),
                      Expanded(
                        child: _pointsCard(
                          "Delivery",
                          deliveryPoints
                              .toString(),
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pointsCard(
      String title,
      String value,
      Color color) {
    return Container(
      padding:
          const EdgeInsets.all(
              18),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(
                20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  void _showSettingsDialog(
    BuildContext context,
    LanguageProvider lang,
    ThemeProvider theme,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text(
                "Dark Mode"),
            value:
                theme.isDarkMode,
            onChanged: (v) {
              theme
                  .toggleTheme();
              Navigator.pop(
                  context);
            },
          ),
        ],
      ),
    );
  }
}