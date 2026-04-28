import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/waafi_payment_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map product;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  final TextEditingController phoneController =
      TextEditingController();

  bool isLoading = false;

  Future<void> buyProduct() async {
    try {
      setState(() {
        isLoading = true;
      });

      final String customerPhone =
          phoneController.text.trim();

      if (customerPhone.isEmpty) {
        throw "Fadlan geli number-ka";
      }

      final double price =
          double.tryParse(
                widget.product["price"]
                    .toString(),
              ) ??
              0;

      final String merchantId =
          widget.product["merchantId"]
              .toString();

      final String orderId = DateTime.now()
          .millisecondsSinceEpoch
          .toString();

      // REAL PAYMENT API
      final result =
          await WaafiPaymentService.makePayment(
        phone: customerPhone,
        amount: price,
        referenceId: orderId,
        description:
            "Purchase ${widget.product["name"]}",
      );

      if (result["responseMsg"] !=
          "RCS_SUCCESS") {
        throw "Payment failed";
      }

      double commission = price * 0.10;
      double merchantProfit =
          price - commission;

      // SAVE ORDER
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId)
          .set({
        "orderId": orderId,
        "productId": widget.productId,
        "productName":
            widget.product["name"],
        "customerPhone":
            customerPhone,
        "price": price,
        "merchantId": merchantId,
        "commission": commission,
        "merchantProfit":
            merchantProfit,
        "status": "paid",
        "paymentMethod":
            "Waafi EVC",
        "createdAt":
            Timestamp.now(),
      });

      // UPDATE MERCHANT WALLET
      await FirebaseFirestore.instance
          .collection("merchant")
          .doc(merchantId)
          .update({
        "wallet": FieldValue.increment(
            merchantProfit)
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "✅ Order successful & payment completed"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showBuyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: const Text(
            "Geli Number-ka EVC"),
        content: TextField(
          controller: phoneController,
          keyboardType:
              TextInputType.phone,
          decoration:
              const InputDecoration(
            labelText:
                "EVC / Waafi Number",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    dialogContext),
            child:
                const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(
                  dialogContext);

              await buyProduct();
            },
            child:
                const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product["name"]),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product["image"],
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              widget.product["name"],
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${widget.product["price"]}",
              style:
                  const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product[
                  "description"],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : showBuyDialog,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Buy Now"),
              ),
            )
          ],
        ),
      ),
    );
  }
}