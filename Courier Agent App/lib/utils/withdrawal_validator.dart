import '../models/earnings_model.dart';

/// Validates a courier's withdrawal request against the current
/// [PayoutSummary] before it is submitted. Extracted from
/// `withdraw_sheet.dart` so the rules can be unit-tested without a widget
/// harness. Returns a user-facing error message, or `null` when valid.
String? validateWithdrawal({
  required double amount,
  required PayoutSummary payout,
}) {
  if (amount <= 0) {
    return 'Enter a valid amount.';
  }
  if (!payout.isVerified) {
    return 'Bank verification is required before withdrawing.';
  }
  if (amount < payout.withdrawalMin) {
    return 'Minimum withdrawal is ৳${payout.withdrawalMin.toStringAsFixed(0)}.';
  }
  if (amount > payout.balance) {
    return 'Amount exceeds your available balance of ৳${payout.balance.toStringAsFixed(2)}.';
  }
  return null;
}
