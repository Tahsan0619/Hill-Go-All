class DailyEarning {
  const DailyEarning({
    required this.date,
    required this.total,
    required this.basePay,
    required this.tips,
    required this.surges,
    required this.deliveries,
  });

  final DateTime date;
  final double total;
  final double basePay;
  final double tips;
  final double surges;
  final int deliveries;
}

class WeeklySummary {
  const WeeklySummary({
    required this.total,
    required this.percentChange,
    required this.totalDeliveries,
    required this.activeHours,
    required this.avgPerHour,
  });

  final double total;
  final double percentChange;
  final int totalDeliveries;
  final double activeHours;
  final double avgPerHour;
}

class PayoutTransaction {
  const PayoutTransaction({
    required this.id,
    required this.dateTime,
    required this.bankName,
    required this.accountLastFour,
    required this.amount,
  });

  final String id;
  final DateTime dateTime;
  final String bankName;
  final String accountLastFour;
  final double amount;
}

class PayoutSummary {
  const PayoutSummary({
    required this.nextPayoutDate,
    required this.totalProcessed,
    required this.bankLastFour,
    required this.isVerified,
    required this.deliveriesCompleted,
    required this.weeklyGoalPercent,
    required this.transactions,
  });

  final DateTime nextPayoutDate;
  final double totalProcessed;
  final String bankLastFour;
  final bool isVerified;
  final int deliveriesCompleted;
  final double weeklyGoalPercent;
  final List<PayoutTransaction> transactions;
}

class DashboardStats {
  const DashboardStats({
    required this.todayEarnings,
    required this.distanceKm,
    required this.performanceRank,
    required this.bonusMultiplier,
    required this.earningsTrend,
    required this.trendPercent,
  });

  final double todayEarnings;
  final double distanceKm;
  final String performanceRank;
  final double bonusMultiplier;
  final List<double> earningsTrend;
  final double trendPercent;
}
