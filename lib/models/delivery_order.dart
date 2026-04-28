class DeliveryOrder {
  final String id;
  final String pickupDistrict;
  final String dropoffDistrict;
  final String productType;
  final double distance;
  final double price;
  final String status; // pending, accepted, completed

  DeliveryOrder({
    required this.id,
    required this.pickupDistrict,
    required this.dropoffDistrict,
    required this.productType,
    required this.distance,
    required this.price,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupDistrict': pickupDistrict,
      'dropoffDistrict': dropoffDistrict,
      'productType': productType,
      'distance': distance,
      'price': price,
      'status': status,
    };
  }

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'],
      pickupDistrict: map['pickupDistrict'],
      dropoffDistrict: map['dropoffDistrict'],
      productType: map['productType'],
      distance: map['distance'],
      price: map['price'],
      status: map['status'],
    );
  }
}