import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOrder {
  final String id;
  final String customerName;
  final String pickupDistrict;
  final String dropoffDistrict;
  final String productType;
  final double deliveryFee;
  final String status;
  final DateTime createdAt;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.pickupDistrict,
    required this.dropoffDistrict,
    required this.productType,
    required this.deliveryFee,
    required this.status,
    required this.createdAt,
  });

  // Xogta ka timaada Firebase u beddel Model
  factory DeliveryOrder.fromMap(Map<String, dynamic> map, String docId) {
    return DeliveryOrder(
      id: docId,
      customerName: map['customerName'] ?? '',
      pickupDistrict: map['pickupDistrict'] ?? '',
      dropoffDistrict: map['dropoffDistrict'] ?? '',
      productType: map['productType'] ?? '',
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Model-ka u beddel Map si loogu diro Firebase
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'pickupDistrict': pickupDistrict,
      'dropoffDistrict': dropoffDistrict,
      'productType': productType,
      'deliveryFee': deliveryFee,
      'status': status,
      'createdAt': createdAt,
    };
  }
}