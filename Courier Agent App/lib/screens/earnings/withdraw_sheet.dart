import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/earnings_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});
  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  static const _methods = ['bKash', 'Nagad', 'Bank'];

  final _amount = TextEditingController();
  String _method = 'bKash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EarningsProvider>().loadPayout();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _confirm(EarningsProvider earnings) async {
    final entered = double.tryParse(_amount.text.trim()) ?? 0;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final payout = earnings.payout;
    if (payout == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Balance is not available yet.')));
      return;
    }
    if (entered <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    if (!payout.isVerified) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Bank verification is required before withdrawing.')),
      );
      return;
    }
    if (entered < payout.withdrawalMin) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Minimum withdrawal is ৳${payout.withdrawalMin.toStringAsFixed(0)}.',
          ),
        ),
      );
      return;
    }
    if (entered > payout.balance) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Amount exceeds your available balance of ৳${payout.balance.toStringAsFixed(2)}.',
          ),
        ),
      );
      return;
    }
    final ok = await earnings.withdraw(amount: entered, method: _method);
    if (!mounted) return;
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(earnings.error ?? 'Withdrawal failed.')));
      return;
    }
    await showDialog<void>(
      context: nav.context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Withdrawal requested'),
        content: Text(
          '৳${entered.toStringAsFixed(2)} via $_method has been submitted for processing. '
          'You will be notified once it is approved.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
      ),
    );
    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final earnings = context.watch<EarningsProvider>();
    final payout = earnings.payout;
    return Scaffold(
      appBar: const HillGoAppBar(title: 'Withdraw Funds', showBack: true, showBell: false),
      body: earnings.state == EarningsLoadState.loading && payout == null
          ? const LoadingView(message: 'Loading your balance...')
          : payout == null
              ? ErrorView(
                  message: earnings.error ?? 'Could not load your balance.',
                  onRetry: () => context.read<EarningsProvider>().loadPayout(),
                )
              : ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
                  AppCard(color: AppColors.primary, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AVAILABLE BALANCE', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text('৳${payout.balance.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      payout.isVerified
                          ? 'Transfers go to your verified account (•••• ${payout.bankLastFour}).'
                          : 'Bank verification is pending — withdrawals unlock once verified.',
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ])),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Withdrawal amount', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '৳ ',
                      hintText: '0.00',
                      helperText: 'Minimum withdrawal ৳${payout.withdrawalMin.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Payout method', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Row(
                    children: _methods
                        .map((method) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: method == _methods.last ? 0 : 8),
                                child: ChoiceChip(
                                  label: Text(method),
                                  selected: _method == method,
                                  onSelected: (_) => setState(() => _method = method),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _method == method ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Confirm Withdrawal',
                    loading: earnings.withdrawing,
                    onPressed: () => _confirm(earnings),
                  ),
                ]),
    );
  }
}
