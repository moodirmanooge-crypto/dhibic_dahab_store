import 'package:flutter/material.dart';
import '../models/product_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Product> products = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  void addProduct() {
    setState(() {
      products.add(
        Product(
          id: DateTime.now().toString(),
          name: nameController.text,
          price: double.parse(priceController.text),
          category: 'General',
        ),
      );
    });
    nameController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: addProduct,
              child: const Text('Add Product'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(products[i].name),
                  trailing: Text('\$${products[i].price}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
