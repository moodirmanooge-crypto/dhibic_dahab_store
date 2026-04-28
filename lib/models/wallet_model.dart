class WalletModel {
  double balance;
  double totalEarned;
  double commissionPaid;

  WalletModel({
    required this.balance,
    required this.totalEarned,
    required this.commissionPaid,
  });

  factory WalletModel.fromMap(Map<String, dynamic> data) {
    return WalletModel(
      balance: data['balance'] ?? 0,
      totalEarned: data['totalEarned'] ?? 0,
      commissionPaid: data['commissionPaid'] ?? 0,
    );
  }
}