import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details.dart';

class CategoryProducts extends StatefulWidget {
  final String category;

  const CategoryProducts({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProducts> createState() =>
      _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  String selectedTab = "All";

  // 🔥 GET DISCOUNT
  Future<double> getCategoryDiscount() async {
    final doc = await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.category.toLowerCase())
        .get();

    if (!doc.exists) return 0;

    final data = doc.data() as Map<String, dynamic>;

    final discountText = data["discount"]?.toString() ?? "";

    final percent = double.tryParse(
          discountText
              .replaceAll("%", "")
              .replaceAll("OFF", "")
              .trim(),
        ) ??
        0;

    return percent;
  }

  // 🔥 TYPE TABS (MAIN TABS)
  List<String> getTypeTabs(List<QueryDocumentSnapshot> products) {
    final Set<String> tabs = {"All"};

    for (var doc in products) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data["type"];

      if (type != null && type.toString().isNotEmpty) {
        tabs.add(type);
      }
    }

    return tabs.toList();
  }

  // 🔥 FILTER BY TYPE
  List<QueryDocumentSnapshot> filterProducts(
    List<QueryDocumentSnapshot> products,
  ) {
    if (selectedTab == "All") return products;

    return products.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data["type"] == selectedTab;
    }).toList();
  }

  // 🔥 GET SUBCATEGORY LIST INSIDE TAB
  List<String> getSubCategoryTabs(
      List<QueryDocumentSnapshot> products) {
    final Set<String> tabs = {};

    for (var doc in products) {
      final data = doc.data() as Map<String, dynamic>;
      final sub = data["subCategory"];

      if (sub != null && sub.toString().isNotEmpty) {
        tabs.add(sub);
      }
    }

    return tabs.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE7F6),
        elevation: 0,
        title: Text(
          widget.category.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<double>(
        future: getCategoryDiscount(),
        builder: (context, discountSnap) {
          if (!discountSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final discount = discountSnap.data ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("products")
                .where("category", isEqualTo: widget.category)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final products = snapshot.data!.docs;

              if (products.isEmpty) {
                return const Center(
                  child: Text("No products"),
                );
              }

              final tabs = getTypeTabs(products);
              final filtered = filterProducts(products);
              final subTabs = getSubCategoryTabs(filtered);

              return Column(
                children: [

                  // 🔥 TYPE TABS (ARABAN STYLE)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tab = tabs[index];
                        final isActive = selectedTab == tab;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = tab;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tab.toUpperCase(),
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (isActive)
                                  Container(
                                    height: 3,
                                    width: 30,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔥 SUBCATEGORY LIST (LIKE ARBAN)
                  if (subTabs.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subTabs.length,
                        itemBuilder: (context, index) {
                          final sub = subTabs[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                sub,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 🔥 PRODUCTS GRID
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data =
                            doc.data() as Map<String, dynamic>;

                        final oldPrice =
                            double.tryParse(data["price"].toString()) ?? 0;

                        double newPrice = oldPrice;

                        if (discount > 0) {
                          newPrice =
                              oldPrice - (oldPrice * discount / 100);
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetails(product: data),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  child: SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: data["image"] != ""
                                        ? Image.network(
                                            data["image"],
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.image, size: 80),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data["name"] ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "\$${newPrice.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}