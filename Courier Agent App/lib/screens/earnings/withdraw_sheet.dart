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
  final _amount = TextEditingController(text: '1248.50');
  bool _simulateFailure = false;
  @override
  void dispose() { _amount.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final earnings = context.watch<EarningsProvider>();
    const available = 1248.50;
    return Scaffold(
      appBar: const HillGoAppBar(title: 'Withdraw Funds', showBack: true, showBell: false),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        AppCard(color: AppColors.primary, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AVAILABLE BALANCE', style: AppTextStyles.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('\$${available.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Instant transfer to your verified bank account', style: AppTextStyles.body.copyWith(color: Colors.white70)),
        ])),
        const SizedBox(height: AppSpacing.xl),
        Text('Withdrawal amount', style: AppTextStyles.h3),
        const SizedBox(height: 8),
        TextField(
          controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          value: _simulateFailure, onChanged: (v) => setState(() => _simulateFailure = v),
          title: const Text('Simulate failure'), subtitle: const Text('Use this to preview an insufficient-balance error.'),
          contentPadding: EdgeInsets.zero, activeThumbColor: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(label: 'Confirm Withdrawal', loading: earnings.withdrawing, onPressed: () async {
          final entered = double.tryParse(_amount.text.trim()) ?? 0;
          final messenger = ScaffoldMessenger.of(context);
          final nav = Navigator.of(context);
          final ok = await earnings.withdraw(_simulateFailure ? available + 1 : entered);
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
              content: Text('\$${entered.toStringAsFixed(2)} will arrive in your bank account shortly.'),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
            ),
          );
          if (mounted) nav.pop();
        }),
      ]),
    );
  }
}
