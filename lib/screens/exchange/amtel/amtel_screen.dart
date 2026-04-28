import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../service/waafi_payment_service.dart';

class AmtelScreen extends StatelessWidget {
  const AmtelScreen({super.key});

  static const Color primaryColor = Color(0xFF060B4F);

  static const List<Map<String, String>> categories = [
    {
      "title": "Bulaal Unlimited",
      "image": "assets/images/bulaal.png",
      "type": "bulaal",
    },
    {
      "title": "Tanaad",
      "image": "assets/images/tanaad.png",
      "type": "tanaad",
    },
    {
      "title": "Amtel Ku Hadal",
      "image": "assets/images/amtel.png",
      "type": "amtel",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Amtel",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final item = categories[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AmtelPackagesScreen(
                    title: item["title"]!,
                    type: item["type"]!,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.asset(
                        item["image"]!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item["title"]!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AmtelPackagesScreen extends StatelessWidget {
  final String title;
  final String type;

  const AmtelPackagesScreen({
    super.key,
    required this.title,
    required this.type,
  });

  List<Map<String, String>> get packages {
    if (type == "bulaal") {
      return [
        {
          "title": "Bulaal Unlimited",
          "old": "\$0.25",
          "new": "\$0.23",
          "desc": "10 saac",
          "image": "assets/images/bulaal.png",
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$0.5",
          "new": "\$0.46",
          "desc": "36 saac",
          "image": "assets/images/bulaal.png",
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$1",
          "new": "\$0.92",
          "desc": "6 maalin",
          "image": "assets/images/bulaal.png",
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$2.5",
          "new": "\$2.30",
          "desc": "1 usbuuc",
          "image": "assets/images/bulaal.png",
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$10",
          "new": "\$9.20",
          "desc": "1 bil",
          "image": "assets/images/bulaal.png",
        },
      ];
    }

    if (type == "tanaad") {
      return [
        {
          "title": "Tanaad",
          "old": "\$0.1",
          "new": "\$0.09",
          "desc": "500MB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$0.25",
          "new": "\$0.24",
          "desc": "1GB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$0.5",
          "new": "\$0.46",
          "desc": "2GB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$1",
          "new": "\$0.92",
          "desc": "4GB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$3",
          "new": "\$2.76",
          "desc": "10GB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$5",
          "new": "\$4.60",
          "desc": "25GB",
          "image": "assets/images/tanaad.png",
        },
        {
          "title": "Tanaad",
          "old": "\$8",
          "new": "\$7.36",
          "desc": "51GB",
          "image": "assets/images/tanaad.png",
        },
      ];
    }

    return [
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.1",
        "new": "\$0.10",
        "desc": "3 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.25",
        "new": "\$0.25",
        "desc": "7 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.5",
        "new": "\$0.48",
        "desc": "15 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$1",
        "new": "\$0.94",
        "desc": "30 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$2",
        "new": "\$1.88",
        "desc": "60 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$3",
        "new": "\$2.82",
        "desc": "90 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$5",
        "new": "\$4.70",
        "desc": "180 maalin",
        "image": "assets/images/amtel.png",
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$10",
        "new": "\$9.40",
        "desc": "365 maalin",
        "image": "assets/images/amtel.png",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: AmtelScreen.primaryColor,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: packages.length,
        itemBuilder: (_, index) {
          final item = packages[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AmtelPaymentScreen(
                    itemName: item["title"]!,
                    amount: double.parse(
                      item["new"]!.replaceAll("\$", ""),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Image.asset(
                    item["image"]!,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"]!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              item["old"]!,
                              style: const TextStyle(
                                color: Colors.red,
                                decoration:
                                    TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item["new"]!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(item["desc"]!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AmtelPaymentScreen extends StatefulWidget {
  final String itemName;
  final double amount;

  const AmtelPaymentScreen({
    super.key,
    required this.itemName,
    required this.amount,
  });

  @override
  State<AmtelPaymentScreen> createState() =>
      _AmtelPaymentScreenState();
}

class _AmtelPaymentScreenState
    extends State<AmtelPaymentScreen> {
  final phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> submitPayment() async {
    setState(() => isLoading = true);

    final response =
        await WaafiPaymentService.makePayment(
      phone: phoneController.text,
      amount: widget.amount,
      referenceId: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      description: widget.itemName,
    );

    setState(() => isLoading = false);

    if (response["success"] == true ||
        response["responseCode"] == "2001") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AmtelSuccessScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AmtelScreen.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                labelText: "Numberka lacagta",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed:
                  isLoading ? null : submitPayment,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("BIXI LACAGTA"),
            )
          ],
        ),
      ),
    );
  }
}

class AmtelSuccessScreen extends StatelessWidget {
  const AmtelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle,
              size: 120,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}