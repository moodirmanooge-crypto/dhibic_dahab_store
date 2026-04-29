import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat/chat_screen.dart';

class ProductDetail extends StatefulWidget {
  final Map product;

  const ProductDetail({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetail> createState() =>
      _ProductDetailState();
}

class _ProductDetailState
    extends State<ProductDetail> {
  int selectedIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  Future<void> addToCart() async {
    String userId =
        FirebaseAuth.instance.currentUser!.uid;

    String productId =
        widget.product["id"] ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString();

    List<String> images = [];

    if (widget.product["images"] != null &&
        widget.product["images"] is List) {
      images = List<String>.from(
          widget.product["images"]);
    } else if (widget.product["image"] != null &&
        widget.product["image"]
            .toString()
            .isNotEmpty) {
      images = [
        widget.product["image"].toString()
      ];
    }

    await FirebaseFirestore.instance
        .collection("cart")
        .doc(userId)
        .collection("items")
        .doc(productId)
        .set({
      "name": widget.product["name"],
      "price": widget.product["price"],
      "image": images.isNotEmpty
          ? images[selectedIndex]
          : "",
      "quantity": 1,
      "merchantId":
          widget.product["merchantId"],
      "createdAt":
          FieldValue.serverTimestamp(),
    });

    // ✅ Hubi haddii widget-ku uu weli jiro ka hor intaanan isticmaalin context
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text("Added to cart"),
      ),
    );
  }

  /// ✅ CHAT BUTTON FUNCTION
  Future<void> openChat() async {
    String customerId =
        FirebaseAuth.instance.currentUser!.uid;

    String merchantId =
        widget.product["merchantId"]
            .toString();

    String merchantName =
        widget.product["merchantName"]
                ?.toString() ??
            "Merchant";

    String productName =
        widget.product["name"]
            .toString();

    String chatId =
        "${customerId}_$merchantId";

    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        "customerId": customerId,
        "customerName": "Customer",
        "merchantId": merchantId,
        "merchantName": merchantName,
        "productName": productName,
        "lastMessage": "",
        "lastMessageTime":
            FieldValue.serverTimestamp(),
        "customerSeen": true,
        "merchantSeen": false,
      });
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          merchantName: merchantName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = [];

    if (widget.product["images"] != null &&
        widget.product["images"] is List) {
      images = List<String>.from(
          widget.product["images"]);
    } else if (widget.product["image"] != null &&
        widget.product["image"]
            .toString()
            .isNotEmpty) {
      images = [
        widget.product["image"].toString()
      ];
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
        actions: const [
          Icon(Icons.search,
              color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.shopping_cart,
              color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 300,
            child: images.isNotEmpty
                ? PageView.builder(
                    controller:
                        pageController,
                    itemCount:
                        images.length,
                    onPageChanged: (i) {
                      setState(() {
                        selectedIndex =
                            i;
                      });
                    },
                    itemBuilder: (_, i) {
                      return Image.network(
                        images[i],
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Container(
                    color:
                        Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 80,
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => Container(
                margin:
                    const EdgeInsets
                        .symmetric(
                            horizontal:
                                3),
                width:
                    selectedIndex == i
                        ? 10
                        : 6,
                height:
                    selectedIndex == i
                        ? 10
                        : 6,
                decoration:
                    BoxDecoration(
                  color:
                      selectedIndex ==
                              i
                          ? Colors
                              .orange
                          : Colors.grey,
                  shape:
                      BoxShape.circle,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
                const EdgeInsets.all(
                    15),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(
                    20),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  widget.product["name"]
                          ?.toString() ??
                      "No Name",
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  "\$${widget.product["price"]}",
                  style:
                      const TextStyle(
                    fontSize: 20,
                    color:
                        Colors.orange,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 15),

                const Text(
                  "Description",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                    height: 5),

                Text(
                  widget.product[
                              "description"]
                          ?.toString() ??
                      "",
                ),

                const SizedBox(
                    height: 25),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed:
                            openChat,
                        child:
                            const Text(
                          "Chat",
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 10),

                    Expanded(
                      child:
                          ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors
                                  .orange,
                        ),
                        onPressed:
                            addToCart,
                        child:
                            const Text(
                          "Buy Now",
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}