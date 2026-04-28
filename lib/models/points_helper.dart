class PointsHelper {
  static double moneyToPoints(double amount) {
    return amount * 0.01;
  }

  static bool canRedeem(double points) {
    return points >= 700;
  }
}
