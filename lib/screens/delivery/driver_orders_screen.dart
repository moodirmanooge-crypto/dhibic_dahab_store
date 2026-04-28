import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../service/notification_service.dart';

class DriverOrdersScreen extends StatefulWidget {
  final String driverId;

  const DriverOrdersScreen({
    super.key,
    required this.driverId,
  });

  @override
  State<DriverOrdersScreen> createState() =>
      _DriverOrdersScreenState();
}

class _DriverOrdersScreenState
    extends State<DriverOrdersScreen> {
  final String databaseUrl =
      "https://dhibic-dahab-online-store-default-rtdb.europe-west1.firebasedatabase.app/";

  late final DatabaseReference dbRef;
  bool notificationShown = false;

  @override
  void initState() {
    super.initState();

    dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref("orders");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Orders 🚚"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value ==
                  null) {
            return const Center(
              child: Text(
                "No Orders Available",
              ),
            );
          }

          final data =
              snapshot.data!.snapshot.value;

          final Map<dynamic, dynamic> values =
              Map<dynamic, dynamic>.from(
            data as Map,
          );

          final orders = values.entries
              .where(
                (e) =>
                    e.value["status"] ==
                    "pending",
              )
              .toList();

          if (orders.isEmpty) {
            notificationShown = false;
            return const Center(
              child: Text(
                "No Pending Orders",
              ),
            );
          }

          if (!notificationShown) {
            notificationShown = true;
            NotificationService
                .showNotification(
              title: "New Delivery",
              body:
                  "Order cusub ayaa yimid",
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final String orderId =
                  order.key.toString();

              final Map<String, dynamic>
                  orderData =
                  Map<String, dynamic>.from(
                order.value,
              );

              return Card(
                margin:
                    const EdgeInsets.all(
                        12),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "📦 ${orderData["product"] ?? ""}",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "📍 ${orderData["pickup"] ?? ""} → ${orderData["dropoff"] ?? ""}",
                      ),
                      Text(
                        "📞 ${orderData["phone"] ?? ""}",
                      ),
                      Text(
                        "💵 ${orderData["price"] ?? ""}",
                      ),
                      Text(
                        "🏠 ${orderData["address"] ?? ""}",
                      ),
                      Text(
                        "🕒 ${orderData["date"] ?? ""}",
                      ),
                      const SizedBox(
                          height: 12),
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,
                          ),
                          onPressed: () =>
                              acceptOrder(
                            orderId,
                            orderData,
                          ),
                          child:
                              const Text(
                            "Accept Order",
                            style:
                                TextStyle(
                              color: Colors
                                  .white,
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

  Future<void> acceptOrder(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref =
          FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      ).ref();

      double totalPrice = 1.0;

      final rawPrice =
          data["price"]
                  ?.toString() ??
              "1";

      if (rawPrice.contains("\$")) {
        totalPrice = double.tryParse(
              rawPrice.replaceAll(
                  "\$", ""),
            ) ??
            1.0;
      } else {
        totalPrice =
            double.tryParse(
                  rawPrice,
                ) ??
                1.0;
      }

      final double commission =
          totalPrice * 0.07;

      final double driverAmount =
          totalPrice - commission;

      await ref
          .child("orders")
          .child(orderId)
          .update({
        "status": "accepted",
        "driverId":
            widget.driverId,
        "acceptedAt":
            DateTime.now()
                .toIso8601String(),
        "pickup":
            data["pickup"],
        "dropoff":
            data["dropoff"],
        "phone":
            data["phone"],
        "price":
            data["price"],
        "payment":
            data["payment"] ??
                "Waafi",
        "address":
            data["address"],
        "customerImage":
            data["customerImage"],
      });

      await ref
          .child("driver_wallet")
          .child(widget.driverId)
          .runTransaction(
        (Object? currentData) {
          Map<String, dynamic>
              wallet = currentData ==
                      null
                  ? {
                      "balance": 0.0,
                      "commission":
                          0.0,
                      "totalOrders":
                          0,
                    }
                  : Map<String,
                          dynamic>.from(
                      currentData
                          as Map);

          wallet["balance"] =
              (wallet["balance"] ??
                      0.0) +
                  driverAmount;

          wallet["commission"] =
              (wallet["commission"] ??
                      0.0) +
                  commission;

          wallet["totalOrders"] =
              (wallet["totalOrders"] ??
                      0) +
                  1;

          return Transaction
              .success(wallet);
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            "Accepted | Wallet: \$${driverAmount.toStringAsFixed(2)} | Commission: \$${commission.toStringAsFixed(2)}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }
  }
}