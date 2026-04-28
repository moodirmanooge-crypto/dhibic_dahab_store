import 'package:flutter/material.dart';

class RestaurantMenuScreen extends StatelessWidget {
  final String restaurantName;

  const RestaurantMenuScreen({
    super.key,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {'name': 'Bariis & Hilib', 'price': 5},
      {'name': 'Basto', 'price': 4},
      {'name': 'Canjeero & Maraq', 'price': 3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName),
      ),
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final item = menu[index];

          return ListTile(
            title: Text(item['name'].toString()),
            subtitle: Text('\$${item['price']}'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} added to cart'),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }
}