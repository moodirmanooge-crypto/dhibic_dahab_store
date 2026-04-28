import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDriverOrdersScreen extends StatefulWidget {
  const AdminDriverOrdersScreen({super.key});

  @override
  State<AdminDriverOrdersScreen> createState() =>
      _AdminDriverOrdersScreenState();
}

class _AdminDriverOrdersScreenState
    extends State<AdminDriverOrdersScreen> {
  final String databaseUrl =
      "https://dhibic-dahab-online-store-default-rtdb.europe-west1.firebasedatabase.app/";

  late final DatabaseReference ordersRef;

  @override
  void initState() {
    super.initState();

    ordersRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref("orders");
  }

  Future<Map<String, dynamic>?> getDriverData(
    String driverId,
  ) async {
    final doc = await FirebaseFirestore
        .instance
        .collection("drivers")
        .doc(driverId)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }

  String formatSomaliaTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(rawTime)
          .toUtc()
          .add(const Duration(hours: 3));

      return DateFormat(
        "dd/MM/yyyy hh:mm a",
      ).format(date);
    } catch (e) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Drivers Orders",
        ),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ordersRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!
                      .snapshot
                      .value ==
                  null) {
            return const Center(
              child: Text("No Orders"),
            );
          }

          final raw =
              snapshot.data!.snapshot.value;

          final Map<dynamic, dynamic>
              values = Map<dynamic,
                  dynamic>.from(raw as Map);

          final acceptedOrders =
              values.entries
                  .where(
                    (e) =>
                        e.value["driverId"] !=
                        null,
                  )
                  .toList();

          if (acceptedOrders.isEmpty) {
            return const Center(
              child: Text(
                "No Driver Orders",
              ),
            );
          }

          final Map<String,
                  List<Map<String, dynamic>>>
              groupedOrders = {};

          for (final order
              in acceptedOrders) {
            final data = Map<String,
                dynamic>.from(
              order.value,
            );

            final driverId =
                data["driverId"]
                    .toString();

            if (!groupedOrders
                .containsKey(driverId)) {
              groupedOrders[driverId] =
                  [];
            }

            groupedOrders[driverId]!
                .add(data);
          }

          final driverIds =
              groupedOrders.keys.toList();

          return ListView.builder(
            itemCount: driverIds.length,
            itemBuilder:
                (context, index) {
              final driverId =
                  driverIds[index];

              final orders =
                  groupedOrders[
                      driverId]!;

              return FutureBuilder<
                  Map<String,
                      dynamic>?>(
                future: getDriverData(
                  driverId,
                ),
                builder: (context,
                    driverSnap) {
                  final driver =
                      driverSnap.data;

                  final driverPhoto =
                      driver?["photo"]
                              ?.toString() ??
                          "";

                  return Card(
                    margin:
                        const EdgeInsets
                            .all(12),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(15),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    driverPhoto
                                            .isNotEmpty
                                        ? NetworkImage(
                                            driverPhoto,
                                          )
                                        : null,
                                child: driverPhoto
                                        .isEmpty
                                    ? const Icon(
                                        Icons
                                            .person,
                                      )
                                    : null,
                              ),
                              const SizedBox(
                                  width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      driver?["name"] ??
                                          "Driver",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            22,
                                      ),
                                    ),
                                    Text(
                                      driver?["phone"] ??
                                          "",
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            16,
                                      ),
                                    ),
                                    Text(
                                      "Orders: ${orders.length}",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 15),
                          ...orders.map(
                            (data) =>
                                Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom: 12,
                              ),
                              padding:
                                  const EdgeInsets
                                      .all(
                                12,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .grey
                                    .shade100,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "📦 Product: ${data["product"] ?? ""}",
                                  ),
                                  Text(
                                    "📍 Pickup: ${data["pickup"] ?? ""}",
                                  ),
                                  Text(
                                    "🏠 Dropoff: ${data["dropoff"] ?? ""}",
                                  ),
                                  Text(
                                    "📞 Customer: ${data["phone"] ?? ""}",
                                  ),
                                  Text(
                                    "💳 Payment: ${data["payment"] ?? "Waafi"}",
                                  ),
                                  Text(
                                    "💵 Price: \$${data["price"] ?? 0}",
                                  ),
                                  Text(
                                    "🕒 Somalia Time: ${formatSomaliaTime(data["acceptedAt"]?.toString())}",
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}