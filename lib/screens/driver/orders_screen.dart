import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  final service = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: StreamBuilder(
        stream: service.getOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              var order = docs[i];

              return ListTile(
                title: Text("Price: ${order['price']}"),
                subtitle: Text("KM: ${order['distanceKm']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    service.acceptOrder(order.id, "driver1");
                  },
                  child: Text("Accept"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}