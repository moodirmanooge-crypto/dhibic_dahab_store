import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  final String merchantId;
  final String category; // clothes, restaurant, etc
  final String? type; // women / men / kids / all

  const AddProductScreen({
    super.key,
    required this.merchantId,
    required this.category,
    this.type,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  final List<File> imageFiles = [];

  bool isLoading = false;
  String? selectedSubCategory;

  // 🔥 NEW CATEGORY SYSTEM
  Map<String, Map<String, List<String>>> categoryMap = {
    "clothes": {
      "women": [
        "Hijab",
        "Cabayad",
        "Taraaxad",
        "Dirac",
        "Bacweyn",
        "Bacdhexe",
        "Bacyare",
        "Shoes",
      ],
      "men": [
        "Surwaal",
        "Shirt",
        "Jacket",
        "Macwiis",
        "Shoes",
      ],
      "kids": [
        "Kids Boy",
        "Kids Girl",
        "Shoes",
        "Shirt",
        "Dress",
      ],
    },

    "restaurant": {
      "all": [
        "Foods",
        "Pizza",
        "Hot Drinks",
        "Cold Drinks",
        "Burger",
        "Shuwarma",
      ]
    },

    "pharmacy": {
      "all": [
        "Sharoobo",
        "Kaniini",
        "Goojo",
        "Boomaato",
        "Xafaayad",
      ]
    },

    "electronics": {
      "all": [
        "Smart Phone",
        "Smart Watch",
        "AirPods",
        "Laptops",
        "Printers",
        "Chargers",
        "Lights",
        "Other",
      ]
    },

    "supermarket": {
      "all": [
        "Rice",
        "Sugar",
        "Oil",
        "Pasta",
        "Spices",
        "Water",
        "Juice",
        "Snacks",
      ]
    },

    "machines": {
      "all": [
        "Construction",
        "Farming",
        "Industrial",
        "Tools",
      ]
    },

    "organics": {
      "all": [
        "Fruits",
        "Vegetables",
        "Herbs",
        "Organic Food",
      ]
    },

    "companies": {
      "all": [
        "Services",
        "IT",
        "Logistics",
        "Consulting",
      ]
    },
  };

  // 🔥 GET SUBCATEGORY
  List<String> getSubCategories() {
    final main = widget.category;
    final merchantType = widget.type ?? "all";

    return categoryMap[main]?[merchantType] ??
        categoryMap[main]?["all"] ??
        ["General"];
  }

  // PICK IMAGES
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        imageFiles.addAll(
          picked.map((e) => File(e.path)),
        );
      });
    }
  }

  // ADD PRODUCT
  Future<void> addProduct() async {
    if (imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select images")),
      );
      return;
    }

    if (selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select sub category")),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      List<String> imageUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("product_images")
            .child(
                "${DateTime.now().millisecondsSinceEpoch}_$i");

        await ref.putFile(imageFiles[i]);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      final doc =
          await FirebaseFirestore.instance.collection("products").add({
        "name": nameController.text.trim(),
        "price":
            double.tryParse(priceController.text) ?? 0,
        "description": descController.text.trim(),
        "image": imageUrls.first,
        "images": imageUrls,

        "merchantId": widget.merchantId,

        // 🔥 FINAL STRUCTURE
        "category": widget.category,
        "type": widget.type,
        "subCategory": selectedSubCategory,

        "createdAt": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection("notifications")
          .add({
        "title": "New Product",
        "body": "Merchant added product",
        "productId": doc.id,
        "merchantId": widget.merchantId,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildImagePreview() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageFiles.length,
        itemBuilder: (context, i) {
          return Stack(
            children: [
              Container(
                margin:
                    const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.file(
                    imageFiles[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      imageFiles.removeAt(i);
                    });
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close,
                        size: 14,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subList = getSubCategories();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (imageFiles.isNotEmpty)
              buildImagePreview(),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading ? null : pickImages,
              child: const Text("Select Images"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: "Product Name"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Price"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              // ✅ FIXED: 'value' was deprecated, replaced with 'initialValue'
              initialValue: selectedSubCategory,
              hint: const Text("Select Sub Category"),
              items: subList
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedSubCategory = v;
                });
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              onPressed:
                  isLoading ? null : addProduct,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}