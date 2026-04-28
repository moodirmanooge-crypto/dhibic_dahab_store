import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<void> updateWallet(
    String merchantId,
    double orderPrice,
  ) async {
    try {
      final merchantRef =
          _db
              .collection('merchant')
              .doc(merchantId);

      final merchantSnap =
          await merchantRef.get();

      final data =
          merchantSnap.data() ?? {};

      final oldBalance =
          (data["wallet"] ?? 0)
              .toDouble();

      final commissionPercent =
          (data["commission"] ?? 10)
              .toDouble();

      final commissionAmount =
          orderPrice *
              (commissionPercent /
                  100);

      final merchantEarn =
          orderPrice -
              commissionAmount;

      await merchantRef.update({
        "wallet":
            oldBalance +
                merchantEarn,
        "commissionEarned":
            FieldValue.increment(
                commissionAmount),
        "totalSales":
            FieldValue.increment(
                orderPrice),
      });
    } catch (e) {
      rethrow;
    }
  }
}