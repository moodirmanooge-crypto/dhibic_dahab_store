import 'package:flutter/material.dart';
import 'category_products.dart';

class CategoriesScreen extends StatelessWidget {

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    List categories = [

      {"name":"Restaurants","icon":Icons.restaurant},
      {"name":"Clothes","icon":Icons.checkroom},
      {"name":"Supermarkets","icon":Icons.shopping_cart},
      {"name":"Electronics","icon":Icons.devices},
      {"name":"Pharmacy","icon":Icons.local_hospital},
      {"name":"Companies","icon":Icons.business},
      {"name":"Organics","icon":Icons.eco},
      {"name":"Machines","icon":Icons.precision_manufacturing},
      {"name":"Reading","icon":Icons.menu_book},
      {"name":"Exchange Money","icon":Icons.currency_exchange},

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Categories"),
      ),

      body: GridView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: categories.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),

        itemBuilder:(context,index){

          var cat = categories[index];

          return GestureDetector(

            onTap:(){

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_)=>CategoryProducts(
                    category: cat["name"],
                  ),
                ),
              );

            },

            child: Card(

              elevation:3,

              child:Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children:[

                  Icon(
                    cat["icon"],
                    size:40,
                  ),

                  const SizedBox(height:10),

                  Text(cat["name"])

                ],

              ),

            ),

          );

        },

      ),

    );

  }

}