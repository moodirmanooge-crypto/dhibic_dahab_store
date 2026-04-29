import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveryRequestScreen extends StatefulWidget {
  final bool usePoints;
  const DeliveryRequestScreen({super.key, required this.usePoints});

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  String? pickupDistrict;
  String? dropoffDistrict;
  String? productType;
  bool isLoading = false;

  final List<String> districts = ["Hodan", "Wadajir", "Howlwadaag", "Boondheere", "Kaaraan", "Waaberi"];
  final List<String> products = ["Foods", "Clothes", "Electronics", "Documents", "Others"];

  Future<void> _submitOrder() async {
    if (pickupDistrict == null || dropoffDistrict == null || productType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fadlan buuxi meelaha bannaan!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('delivery_orders').add({
        'customerId': user?.uid ?? "anonymous",
        'customerName': user?.displayName ?? "Unknown User",
        'pickupDistrict': pickupDistrict,
        'dropoffDistrict': dropoffDistrict,
        'productType': productType,
        'deliveryFee': 1.00,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => isLoading = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Successfully! ✅"),
            content: const Text("Dalabkaaga waa la gudbiyey. Driver ayaa dhowaan kuu imaan doona."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    pickupDistrict = null;
                    dropoffDistrict = null;
                    productType = null;
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Khalad ayaa dhacay: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Dhibic Dahab Delivery 🚚",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _buildDropdown("Pickup District", pickupDistrict, (val) => setState(() => pickupDistrict = val)),
            const SizedBox(height: 20),

            _buildDropdown("Dropoff District", dropoffDistrict, (val) => setState(() => dropoffDistrict = val)),
            const SizedBox(height: 20),

            _buildDropdown("Product Type", productType, (val) => setState(() => productType = val), items: products),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text("Delivery Fee", style: TextStyle(color: Colors.grey)),
                  Text(
                    "\$1.00",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Request Delivery 🚚", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, Function(String?) onChanged, {List<String>? items}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey,
      ),
      items: (items ?? districts).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}