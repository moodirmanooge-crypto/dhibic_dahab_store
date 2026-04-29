import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ Waxaan u beddelay meesha saxda ah ee model-ku jiro
import '../models/delivery_order.dart'; 

class DeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Abuuri dalab cusub
  Future<void> createOrder(DeliveryOrder order) async {
    await _db.collection('delivery_orders').add(order.toMap());
  }

  // Soo aqri dalabaadka furan (Live Stream)
  Stream<List<DeliveryOrder>> getOrders() {
    return _db.collection('delivery_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeliveryOrder.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // In dalabka la aqbalo
  Future<void> acceptOrder(String id) async {
    await _db.collection('delivery_orders').doc(id).update({
      'status': 'accepted',
    });
  }
}