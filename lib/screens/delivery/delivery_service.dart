import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_order.dart';

class DeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createOrder(DeliveryOrder order) async {
    await _db.collection('delivery_orders').doc(order.id).set(order.toMap());
  }

  Stream<List<DeliveryOrder>> getOrders() {
    return _db.collection('delivery_orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeliveryOrder.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> acceptOrder(String id) async {
    await _db.collection('delivery_orders').doc(id).update({
      'status': 'accepted',
    });
  }
}