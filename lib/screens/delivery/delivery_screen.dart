import 'dart:math';
import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {

  String pickup = "Hodan";
  String dropoff = "Wadajir";
  String product = "Clothes";

  double distance = 0;
  double price = 0;

  final List<String> districtsList = [
    "Hodan","Wadajir","Hamar Weyne","Yaqshid","Kaaraan",
    "Dayniile","Hamar jajab","Garasbaley","Boondheere",
    "Howlwadaag","Huriwaa","Dharkaynley","Cabdi caziiz",
    "Kaxda","Shangaani","Shibis","Waaberi","Wartanabada",
  ];

  final Map<String, Map<String, double>> districts = {
    "Hodan": {"lat": 2.046, "lng": 45.318},
    "Wadajir": {"lat": 2.120, "lng": 45.250},
    "Hamar Weyne": {"lat": 2.038, "lng": 45.343},
    "Yaqshid": {"lat": 2.150, "lng": 45.400},
    "Kaaraan": {"lat": 2.180, "lng": 45.420},
    "Dayniile": {"lat": 2.070, "lng": 45.200},
    "Hamar jajab": {"lat": 2.037, "lng": 45.360},
    "Garasbaley": {"lat": 1.980, "lng": 45.280},
    "Boondheere": {"lat": 2.060, "lng": 45.380},
    "Howlwadaag": {"lat": 2.090, "lng": 45.300},
    "Huriwaa": {"lat": 2.200, "lng": 45.370},
    "Dharkaynley": {"lat": 2.010, "lng": 45.260},
    "Cabdi caziiz": {"lat": 2.250, "lng": 45.450},
    "Kaxda": {"lat": 1.950, "lng": 45.240},
    "Shangaani": {"lat": 2.030, "lng": 45.390},
    "Shibis": {"lat": 2.080, "lng": 45.370},
    "Waaberi": {"lat": 2.020, "lng": 45.300},
    "Wartanabada": {"lat": 2.100, "lng": 45.290},
  };

  final List<String> products = [
    "Clothes","Mobile phone","Electronics","Food"
  ];

  @override
  void initState() {
    super.initState();
    calculateDistance();
  }

  // 🔥 Haversine Formula
  double calc(lat1, lon1, lat2, lon2) {
    const R = 6371;

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  void calculateDistance() {
    final p = districts[pickup];
    final d = districts[dropoff];

    if (p == null || d == null) return;

    if (pickup == dropoff) {
      setState(() {
        distance = 0;
        price = 0;
      });
      return;
    }

    double km = calc(p['lat']!, p['lng']!, d['lat']!, d['lng']!);

    setState(() {
      distance = km;
      price = km * 0.62; // 🔥 halkii KM = 0.62
    });

    print("KM: $km");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Delivery 🚚")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              value: pickup,
              items: districtsList.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => pickup = v!);
                calculateDistance();
              },
              decoration: InputDecoration(labelText: "Pickup District"),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: dropoff,
              items: districtsList.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => dropoff = v!);
                calculateDistance();
              },
              decoration: InputDecoration(labelText: "Dropoff District"),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: product,
              items: products.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => product = v!);
              },
              decoration: InputDecoration(labelText: "Product Type"),
            ),

            SizedBox(height: 30),

            Text("Distance: ${distance.toStringAsFixed(2)} KM",
                style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text("Price: \$${price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: Colors.green)),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: distance <= 0
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(price: price),
                        ),
                      );
                    },
              child: Text("Request Delivery 🚚"),
            )
          ],
        ),
      ),
    );
  }
}