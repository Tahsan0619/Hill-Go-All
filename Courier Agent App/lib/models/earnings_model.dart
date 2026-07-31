double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _toInt(dynamic value) => _toDouble(value).toInt();

DateTime _date(dynamic value) =>
    value is String ? (DateTime.tryParse(value) ?? DateTime.now()) : DateTime.now();

class DailyEarning {
  const DailyEarning({
    required this.date,
    required this.total,
    required this.basePay,
    required this.surges,
    required this.deliveries,
  });

  /// One row of `daily` from `GET /courier/earnings/weekly`.
  factory DailyEarning.fromJson(Map<String, dynamic> json) => DailyEarning(
    date: _date(json['date']),
    total: _toDouble(json['total']),
    basePay: _toDouble(json['base_pay']),
    surges: _toDouble(json['surges']),
    deliveries: _toInt(json['deliveries']),
  );

  final DateTime date;
  final double total;
  final double basePay;
  final double surges;
  final int deliveries;
}

class WeeklySummary {
  const WeeklySummary({
    required this.total,
    required this.percentChange,
    required this.totalDeliveries,
    required this.avgPerDelivery,
    required this.weeklyGoal,
    required this.weeklyGoalPercent,
    required this.daily,
  });

  /// `GET /courier/earnings/weekly`.
  factory WeeklySummary.fromJson(Map<String, dynamic> json) => WeeklySummary(
    total: _toDouble(json['total']),
    percentChange: _toDouble(json['percent_change']),
    totalDeliveries: _toInt(json['total_deliveries']),
    avgPerDelivery: _toDouble(json['avg_per_delivery']),
    weeklyGoal: _toInt(json['weekly_goal']),
    weeklyGoalPercent: _toDouble(json['weekly_goal_percent']),
    daily: (json['daily'] as List<dynamic>? ?? const [])
        .map((row) => DailyEarning.fromJson(row as Map<String, dynamic>))
        .toList(),
  );

  final double total;
  final double percentChange;
  final int totalDeliveries;
  final double avgPerDelivery;
  final int weeklyGoal;
  final double weeklyGoalPercent;
  final List<DailyEarning> daily;
}

class PayoutTransaction {
  const PayoutTransaction({
    required this.id,
    required this.dateTime,
    required this.method,
    required this.accountLastFour,
    required this.amount,
    required this.status,
  });

  /// One `CourierWithdrawal` row from `GET /courier/earnings/payout-summary`.
  factory PayoutTransaction.fromJson(Map<String, dynamic> json) => PayoutTransaction(
    id: (json['code'] as String?) ?? '${json['id']}',
    dateTime: _date(json['created_at']),
    method: (json['method'] as String?) ?? 'Bank',
    accountLastFour: (json['bank_last4'] as String?) ?? '',
    amount: _toDouble(json['amount']),
    status: (json['status'] as String?) ?? 'pending',
  );

  final String id;
  final DateTime dateTime;
  final String method;
  final String accountLastFour;
  final double amount;
  final String status;
}

class PayoutSummary {
  const PayoutSummary({
    required this.balance,
    required this.nextPayoutDate,
    required this.totalProcessed,
    required this.bankLastFour,
    required this.isVerified,
    required this.deliveriesCompleted,
    required this.withdrawalMin,
    required this.transactions,
  });

  /// `GET /courier/earnings/payout-summary`.
  factory PayoutSummary.fromJson(Map<String, dynamic> json) => PayoutSummary(
    balance: _toDouble(json['balance']),
    nextPayoutDate: _date(json['next_payout_date']),
    totalProcessed: _toDouble(json['total_processed']),
    bankLastFour: (json['bank_last_four'] as String?) ?? '',
    isVerified: json['is_verified'] == true,
    deliveriesCompleted: _toInt(json['deliveries_completed']),
    withdrawalMin: _toDouble(json['withdrawal_min']),
    transactions: (json['transactions'] as List<dynamic>? ?? const [])
        .map((row) => PayoutTransaction.fromJson(row as Map<String, dynamic>))
        .toList(),
  );

  final double balance;
  final DateTime nextPayoutDate;
  final double totalProcessed;
  final String bankLastFour;
  final bool isVerified;
  final int deliveriesCompleted;
  final double withdrawalMin;
  final List<PayoutTransaction> transactions;
}

class DashboardStats {
  const DashboardStats({
    required this.todayEarnings,
    required this.distanceKm,
    required this.deliveriesToday,
    required this.bonusMultiplier,
    required this.earningsTrend,
    required this.trendLabels,
    required this.trendPercent,
    required this.balance,
  });

  /// `GET /courier/earnings/dashboard`.
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final trendRows = (json['earnings_trend'] as List<dynamic>? ?? const [])
        .map((row) => row as Map<String, dynamic>)
        .toList();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final labels = <String>[];
    for (var i = 0; i < trendRows.length; i++) {
      if (i == trendRows.length - 1) {
        labels.add('Today');
      } else {
        final date = _date(trendRows[i]['date']);
        labels.add(weekdays[date.weekday - 1]);
      }
    }
    return DashboardStats(
      todayEarnings: _toDouble(json['today_earnings']),
      distanceKm: _toDouble(json['distance_km']),
      deliveriesToday: _toInt(json['deliveries_today']),
      bonusMultiplier: _toDouble(json['bonus_multiplier']),
      earningsTrend: trendRows.map((row) => _toDouble(row['total'])).toList(),
      trendLabels: labels,
      trendPercent: _toDouble(json['trend_percent']),
      balance: _toDouble(json['balance']),
    );
  }

  final double todayEarnings;
  final double distanceKm;
  final int deliveriesToday;
  final double bonusMultiplier;
  final List<double> earningsTrend;
  final List<String> trendLabels;
  final double trendPercent;
  final double balance;
}
