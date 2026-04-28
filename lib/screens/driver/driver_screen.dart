import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverScreen extends StatefulWidget {
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("orders");

  // DRIVER ID (waxaad badali kartaa mustaqbalka)
  final String driverId = "driver_1";

  void acceptOrder(String orderId, Map data) async {

    // haddii hore loo qaatay → ha ogolaan
    if (data['status'] == "accepted") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order already taken ❌")),
      );
      return;
    }

    await dbRef.child(orderId).update({
      "status": "accepted",
      "driverId": driverId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order accepted ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Panel 🚗"),
        backgroundColor: Colors.orangeAccent,
      ),

      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("No Orders Available"));
          }

          final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final orders = data.entries.toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {

              final orderId = orders[index].key;
              final order = Map<String, dynamic>.from(orders[index].value);

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ROUTE
                      Text(
                        "${order['pickup']} → ${order['dropoff']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text("Product: ${order['product']}"),
                      Text("Distance: ${order['distance'].toStringAsFixed(2)} KM"),
                      Text("Price: \$${order['price'].toStringAsFixed(2)}"),

                      SizedBox(height: 8),

                      // CUSTOMER INFO
                      if (order['phone'] != null)
                        Text("Phone: ${order['phone']}"),
                      if (order['address'] != null)
                        Text("Address: ${order['address']}"),

                      SizedBox(height: 8),

                      Text("Date: ${order['date'] ?? ''}"),

                      SizedBox(height: 10),

                      // BUTTON
                      order['status'] == "pending"
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () =>
                                  acceptOrder(orderId, order),
                              child: Text("Accept Order"),
                            )
                          : Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Taken by ${order['driverId']}",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}