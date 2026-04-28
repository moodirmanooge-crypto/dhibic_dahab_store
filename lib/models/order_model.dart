class OrderModel {
  String id;
  double price;
  double lat;
  double lng;
  String status;
  String? driverId;
  double distanceKm;

  OrderModel({
    required this.id,
    required this.price,
    required this.lat,
    required this.lng,
    required this.status,
    this.driverId,
    required this.distanceKm,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      price: data['price'],
      lat: data['lat'],
      lng: data['lng'],
      status: data['status'],
      driverId: data['driverId'],
      distanceKm: data['distanceKm'],
    );
  }
}