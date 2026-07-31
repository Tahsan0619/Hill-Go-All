import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/earnings_model.dart';
import '../../providers/earnings_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});
  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<EarningsProvider>().loadPayout(); });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HillGoAppBar(title: 'Payout History', showBack: true, showBell: false),
    body: Consumer<EarningsProvider>(builder: (context, provider, _) {
      if (provider.state == EarningsLoadState.loading) return const LoadingView(message: 'Loading payout information...');
      if (provider.state == EarningsLoadState.error) return ErrorView(message: provider.error ?? 'Could not load payout information.', onRetry: provider.loadPayout);
      final payout = provider.payout;
      if (payout == null) return const EmptyView(message: 'No payout information available.');
      return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        AppCard(color: AppColors.primary, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEXT PAYOUT', style: AppTextStyles.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(DateFormat('EEEE, MMMM d').format(payout.nextPayoutDate), style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 14),
          Text('৳${payout.totalProcessed.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
          Text('total processed to date', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(payout.isVerified ? Icons.verified : Icons.warning_amber, size: 17, color: const Color(0xFF9CFFB7)),
            const SizedBox(width: 6),
            Text(
              payout.bankLastFour.isEmpty
                  ? 'No bank account on file yet'
                  : 'Bank •••• ${payout.bankLastFour} ${payout.isVerified ? 'verified' : 'pending verification'}',
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ]),
        ])),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AVAILABLE BALANCE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Text('৳${payout.balance.toStringAsFixed(2)}', style: AppTextStyles.amountSm),
          ]))),
          const SizedBox(width: 12),
          Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DELIVERIES DONE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Text('${payout.deliveriesCompleted}', style: AppTextStyles.amountSm),
          ]))),
        ]),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Recent Transactions'),
        const SizedBox(height: AppSpacing.sm),
        if (payout.transactions.isEmpty)
          const Padding(padding: EdgeInsets.all(30), child: EmptyView(message: 'No withdrawals yet.', icon: Icons.account_balance_outlined))
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: payout.transactions.map(_transactionTile).toList()),
          ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          color: AppColors.accentSoft,
          onTap: () => context.push('/incentives'),
          child: Row(children: [
            const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Boost your earnings', style: AppTextStyles.h3),
              Text('Explore active delivery incentives.', style: AppTextStyles.bodySecondary),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.accent),
          ]),
        ),
      ]);
    }),
  );

  Widget _transactionTile(PayoutTransaction tx) {
    final done = tx.status == 'paid' || tx.status == 'approved';
    final failed = tx.status == 'rejected';
    final color = done ? AppColors.success : (failed ? AppColors.error : AppColors.warning);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        child: Icon(Icons.account_balance, color: color),
      ),
      title: Text('${tx.method} · ${tx.id}', style: AppTextStyles.h3),
      subtitle: Text(
        '${DateFormat('MMM d, yyyy').format(tx.dateTime)}'
        '${tx.accountLastFour.isEmpty ? '' : ' · •••• ${tx.accountLastFour}'}',
        style: AppTextStyles.caption,
      ),
      trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('৳${tx.amount.toStringAsFixed(2)}', style: AppTextStyles.amountSm),
        Text(tx.status.toUpperCase(), style: AppTextStyles.caption.copyWith(color: color)),
      ]),
    );
  }
}
