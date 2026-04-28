import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {

  int _itemCount = 0;

  // ✅ THIS IS THE FIX
  int get itemCount => _itemCount;

  // ➕ ADD ITEM
  void addItem() {
    _itemCount++;
    notifyListeners();
  }

  // ➖ REMOVE ITEM
  void removeItem() {
    if (_itemCount > 0) {
      _itemCount--;
      notifyListeners();
    }
  }

  // 🔄 RESET
  void clearCart() {
    _itemCount = 0;
    notifyListeners();
  }
}