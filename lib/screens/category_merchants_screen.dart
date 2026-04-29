import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'merchant_store_screen.dart';

class CategoryMerchantsScreen extends StatelessWidget {

  final String category;

  const CategoryMerchantsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(category.toUpperCase()),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("merchant")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var merchants = snapshot.data!.docs.where((doc){

            var raw = doc.data();

            if (raw is! Map<String, dynamic>) return false;

            String cat = (raw["category"] ?? "")
                .toString()
                .toLowerCase();

            return cat == category.toLowerCase();

          }).toList();

          if (merchants.isEmpty) {
            return const Center(child: Text("No stores found"));
          }

          return ListView.builder(

            itemCount: merchants.length,

            itemBuilder: (context, index) {

              var doc = merchants[index];

              var raw = doc.data();

              if (raw is! Map<String, dynamic>) {
                return const SizedBox();
              }

              var data = raw;

              String name =
                  data["name"]?.toString() ??
                  data["storeName"]?.toString() ??
                  data["shopName"]?.toString() ??
                  "No Name";

              String image = data["image"]?.toString() ?? "";

              return Card(

                margin: const EdgeInsets.all(8),

                child: ListTile(

                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        image.isNotEmpty ? NetworkImage(image) : null,
                    child: image.isEmpty
                        ? const Icon(Icons.store)
                        : null,
                  ),

                  title: Text(name.toUpperCase()),
                  subtitle: Text(category),

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MerchantStoreScreen(
                          merchantId: doc.id,
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}