import 'package:flutter/material.dart';

// ✅ Model yar oo matalaya alaabta la iibiyey
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  // ✅ Liiska alaabta ku jirta dambiisha (Cart)
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  // ✅ Tirada alaabta (Items count)
  int get itemCount => _items.length;

  // ✅ XALKA ERROR-KA: Wadarta lacagta (Total Amount)
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // ➕ ADD ITEM (Habka saxda ah)
  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // Haddii ay hore u jirtay, kordhi tirada (quantity)
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Haddii ay cusub tahay, ku dar liiska
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // ➖ REMOVE ITEM
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // 🔄 RESET (Nadiifi dambiisha)
  void clearCart() {
    _items = {};
    notifyListeners();
  }
}