import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key}); // ✅ Saxid: Key lagu daray

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
      // ✅ Saxid: Hubinta mounted si looga fogaado async gaps
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order already taken ❌")),
      );
      return;
    }

    await dbRef.child(orderId).update({
      "status": "accepted",
      "driverId": driverId,
    });

    // ✅ Saxid: Hubinta mounted
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order accepted ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Panel 🚗"), // ✅ Saxid: const lagu daray
        backgroundColor: Colors.orangeAccent,
      ),

      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // ✅ Saxid: const
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No Orders Available")); // ✅ Saxid: const
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
                margin: const EdgeInsets.all(10), // ✅ Saxid: const
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12), // ✅ Saxid: const
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ROUTE
                      Text(
                        "${order['pickup']} → ${order['dropoff']}",
                        style: const TextStyle( // ✅ Saxid: const
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6), // ✅ Saxid: const

                      Text("Product: ${order['product']}"),
                      Text("Distance: ${order['distance'].toStringAsFixed(2)} KM"),
                      Text("Price: \$${order['price'].toStringAsFixed(2)}"),

                      const SizedBox(height: 8), // ✅ Saxid: const

                      // CUSTOMER INFO
                      if (order['phone'] != null)
                        Text("Phone: ${order['phone']}"),
                      if (order['address'] != null)
                        Text("Address: ${order['address']}"),

                      const SizedBox(height: 8), // ✅ Saxid: const

                      Text("Date: ${order['date'] ?? ''}"),

                      const SizedBox(height: 10), // ✅ Saxid: const

                      // BUTTON
                      order['status'] == "pending"
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () =>
                                  acceptOrder(orderId, order),
                              child: const Text("Accept Order"), // ✅ Saxid: const
                            )
                          : Container(
                              padding: const EdgeInsets.all(8), // ✅ Saxid: const
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Taken by ${order['driverId']}",
                                style: const TextStyle(color: Colors.black), // ✅ Saxid: const
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