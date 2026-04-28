import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  // 📦 GET ITEMS
  List<Product> get items => _items;

  // 🔢 TOTAL ITEMS COUNT (badge)
  int get itemCount => _items.length;

  // 💰 TOTAL PRICE
  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  // ➕ ADD PRODUCT (no duplicate)
  void addToCart(Product product) {
    if (!_items.contains(product)) {
      _items.add(product);
      notifyListeners();
    }
  }

  // ➖ REMOVE PRODUCT
  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  // 🧹 CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 🔍 CHECK IF EXISTS
  bool isInCart(Product product) {
    return _items.contains(product);
  }

  // 🔁 TOGGLE (add/remove quickly)
  void toggleCart(Product product) {
    if (isInCart(product)) {
      removeFromCart(product);
    } else {
      addToCart(product);
    }
  }
}