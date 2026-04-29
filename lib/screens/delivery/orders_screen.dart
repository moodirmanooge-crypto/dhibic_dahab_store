import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dalabaadka Cusub 🚚"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Halkan wuxuu ka akhrinayaa dalabaadka status-koodu yahay 'pending'
        stream: FirebaseFirestore.instance
            .collection('delivery_orders')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Ma jiraan dalabaad cusub oo hadda furan."),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var data = order.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.delivery_dining, color: Colors.white),
                  ),
                  title: Text(
                    "${data['pickupDistrict']} ➡️ ${data['dropoffDistrict']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Alaabta: ${data['productType']}"),
                      Text("Lacagta: \$${data['deliveryFee']}"),
                      Text("Macmiilka: ${data['customerName']}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _acceptOrder(context, order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Shaqada lagu aqbalayo dalabka
  Future<void> _acceptOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('delivery_orders')
          .doc(orderId)
          .update({
        'status': 'accepted',
        // 'driverId': FirebaseAuth.instance.currentUser?.uid, // Haddii aad rabto inaad u xirto driver-ka
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dalabka waad aqbashay! ✅")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Khalad ayaa dhacay: $e")),
        );
      }
    }
  }
}