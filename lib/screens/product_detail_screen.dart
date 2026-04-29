import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ Waxaan saxay Import-ka: 'service' ayaan ka dhigay halkii ay ka ahayd 'services'
import '../service/waafi_payment_service.dart';

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
          widget.product["merchantId"]?.toString() ?? "merchant_001";

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

      // ✅ FIX: Waxaan ku daray check-ga Response Code-ka saxda ah
      final bool success = result["responseMsg"] == "RCS_SUCCESS" || 
                          result["responseCode"].toString() == "2001";

      if (!success) {
        throw "Payment failed: ${result["responseMsg"]}";
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
            Text(widget.product["name"] ?? "Detail"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView( // ✅ Lagu daray si haddii keyboard-ku soo baxo uusan error u bixin
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (widget.product["image"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.product["image"],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              widget.product["name"] ?? "Product",
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              widget.product["description"] ?? "No description available.",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : showBuyDialog,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Buy Now",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}