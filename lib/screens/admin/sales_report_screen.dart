import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() =>
      _SalesReportScreenState();
}

class _SalesReportScreenState
    extends State<SalesReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  double totalIncome = 0;
  double totalProfit = 0;
  double totalLoss = 0;

  bool loading = false;

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> loadReport() async {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text("Select dates first"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
      totalIncome = 0;
      totalProfit = 0;
      totalLoss = 0;
    });

    final from = Timestamp.fromDate(
      DateTime(
        fromDate!.year,
        fromDate!.month,
        fromDate!.day,
      ),
    );

    final to = Timestamp.fromDate(
      DateTime(
        toDate!.year,
        toDate!.month,
        toDate!.day,
        23,
        59,
        59,
      ),
    );

    final orders = await FirebaseFirestore
        .instance
        .collection("orders")
        .where("createdAt",
            isGreaterThanOrEqualTo: from)
        .where("createdAt",
            isLessThanOrEqualTo: to)
        .get();

    double income = 0;

    for (var doc in orders.docs) {
      final data = doc.data();

      income +=
          (data["total"] ?? 0)
              .toDouble();

      income +=
          (data["deliveryFee"] ?? 0)
              .toDouble();
    }

    double profit = income * 0.20;
    double loss = income * 0.05;

    setState(() {
      totalIncome = income;
      totalProfit = profit;
      totalLoss = loss;
      loading = false;
    });
  }

  Widget infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 6,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  const Color(0xFFD4AF37),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        title: const Text(
          "Sales Report",
        ),
        backgroundColor:
            const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: pickFromDate,
              child: Text(
                fromDate == null
                    ? "Select From Date"
                    : DateFormat(
                        "dd/MM/yyyy",
                      ).format(
                        fromDate!,
                      ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: pickToDate,
              child: Text(
                toDate == null
                    ? "Select To Date"
                    : DateFormat(
                        "dd/MM/yyyy",
                      ).format(
                        toDate!,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  loading
                      ? null
                      : loadReport,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    const Color(
                        0xFFD4AF37),
              ),
              child: loading
                  ? const CircularProgressIndicator(
                      color:
                          Colors.white,
                    )
                  : const Text(
                      "Generate Report",
                      style: TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 25),
            infoCard(
              "Total Income",
              "\$${totalIncome.toStringAsFixed(2)}",
              Icons
                  .attach_money,
            ),
            infoCard(
              "Profit",
              "\$${totalProfit.toStringAsFixed(2)}",
              Icons.trending_up,
            ),
            infoCard(
              "Loss",
              "\$${totalLoss.toStringAsFixed(2)}",
              Icons.trending_down,
            ),
            infoCard(
              "Profit / Loss",
              "\$${(totalProfit - totalLoss).toStringAsFixed(2)}",
              Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }
}