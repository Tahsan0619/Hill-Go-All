import 'package:flutter_test/flutter_test.dart';
import 'package:courier_agent_app/models/earnings_model.dart';
import 'package:courier_agent_app/utils/withdrawal_validator.dart';

PayoutSummary _payout({
  double balance = 1000,
  bool isVerified = true,
  double withdrawalMin = 100,
}) {
  return PayoutSummary(
    balance: balance,
    nextPayoutDate: DateTime(2026, 1, 1),
    totalProcessed: 0,
    bankLastFour: '1234',
    isVerified: isVerified,
    deliveriesCompleted: 0,
    withdrawalMin: withdrawalMin,
    transactions: const [],
  );
}

void main() {
  group('validateWithdrawal', () {
    test('rejects zero or negative amounts', () {
      expect(validateWithdrawal(amount: 0, payout: _payout()), 'Enter a valid amount.');
      expect(validateWithdrawal(amount: -5, payout: _payout()), 'Enter a valid amount.');
    });

    test('requires bank verification', () {
      final error = validateWithdrawal(amount: 500, payout: _payout(isVerified: false));
      expect(error, 'Bank verification is required before withdrawing.');
    });

    test('enforces the minimum withdrawal', () {
      final error = validateWithdrawal(amount: 50, payout: _payout(withdrawalMin: 100));
      expect(error, 'Minimum withdrawal is ৳100.');
    });

    test('rejects amounts above the available balance', () {
      final error = validateWithdrawal(amount: 1500, payout: _payout(balance: 1000));
      expect(error, 'Amount exceeds your available balance of ৳1000.00.');
    });

    test('accepts a valid amount within range', () {
      final error = validateWithdrawal(
        amount: 500,
        payout: _payout(balance: 1000, withdrawalMin: 100),
      );
      expect(error, isNull);
    });

    test('accepts an amount exactly at the minimum or the balance', () {
      final payout = _payout(balance: 1000, withdrawalMin: 100);
      expect(validateWithdrawal(amount: 100, payout: payout), isNull);
      expect(validateWithdrawal(amount: 1000, payout: payout), isNull);
    });
  });
}
