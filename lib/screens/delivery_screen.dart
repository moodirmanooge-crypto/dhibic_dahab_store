import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  // 🔥 DATABASE REFERENCE
  final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://dhibic-dahab-online-store-default-rtdb.europe-west1.firebasedatabase.app/",
  ).ref("orders");

  final String driverId = "driver_1";

  // TEST ORDER DATA
  String pickup = "Hodan";
  String dropoff = "Wadajir";
  String product = "Foods";
  double distance = 3.80;
  double price = 1.0;

  // 🔥 SEND TEST ORDER
  void sendOrder() async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    await dbRef.child(id).set({
      "id": id,
      "pickup": pickup,
      "dropoff": dropoff,
      "product": product,
      "distance": distance,
      "price": price,
      "status": "pending",
      "time": DateTime.now().toString(),
      "driverId": "",
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Order Successfully Sent"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔥 ACCEPT ORDER
  void acceptOrder(String orderId, Map data) async {
    if (data['status'] == "accepted") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order already taken ❌"),
        ),
      );
      return;
    }

    await dbRef.child(orderId).update({
      "status": "accepted",
      "driverId": driverId,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order accepted ✅"),
      ),
    );
  }

  // 🔥 ORDER BADGE ICON
  Widget buildOrderBadge() {
    return StreamBuilder<DatabaseEvent>(
      stream: dbRef.onValue,
      builder: (context, snapshot) {
        int pendingCount = 0;

        if (snapshot.hasData &&
            snapshot.data!.snapshot.value != null) {
          final values = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          pendingCount = values.values
              .where(
                (e) =>
                    Map<String, dynamic>.from(e)["status"] ==
                    "pending",
              )
              .length;
        }

        return Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.notifications,
                size: 28,
              ),
            ),
            if (pendingCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$pendingCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Panel 🚗"),
        backgroundColor: Colors.orangeAccent,
        actions: [
          buildOrderBadge(),

          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: sendOrder,
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text("No Orders Available"),
            );
          }

          final Map<dynamic, dynamic> rawData =
              Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final orders = rawData.entries.toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderId =
                  orders[index].key.toString();

              final order =
                  Map<String, dynamic>.from(
                orders[index].value as Map,
              );

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${order['pickup']} → ${order['dropoff']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                          "Product: ${order['product']}"),
                      Text(
                          "Distance: ${order['distance']?.toString() ?? '0'} KM"),
                      Text(
                          "Price: \$${order['price']?.toString() ?? '0'}"),

                      const SizedBox(height: 8),

                      if (order['phone'] != null)
                        Text(
                            "Phone: ${order['phone']}"),

                      if (order['address'] != null)
                        Text(
                            "Address: ${order['address']}"),

                      const SizedBox(height: 8),

                      Text(
                          "Date: ${order['time'] ?? order['date'] ?? ''}"),

                      const SizedBox(height: 10),

                      order['status'] == "pending"
                          ? ElevatedButton(
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.green,
                                minimumSize:
                                    const Size(
                                  double.infinity,
                                  40,
                                ),
                              ),
                              onPressed: () =>
                                  acceptOrder(
                                orderId,
                                order,
                              ),
                              child: const Text(
                                "Accept Order",
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .all(10),
                              decoration:
                                  BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            8),
                              ),
                              child: Center(
                                child: Text(
                                  "Taken by ${order['driverId']}",
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),
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