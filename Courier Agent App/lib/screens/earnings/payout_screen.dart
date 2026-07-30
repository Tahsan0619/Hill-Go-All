import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
          Text('\$${payout.totalProcessed.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(payout.isVerified ? Icons.verified : Icons.warning_amber, size: 17, color: const Color(0xFF9CFFB7)),
            const SizedBox(width: 6),
            Text('Bank •••• ${payout.bankLastFour} ${payout.isVerified ? 'verified' : 'pending'}', style: AppTextStyles.body.copyWith(color: Colors.white70)),
          ]),
        ])),
        const SizedBox(height: AppSpacing.lg),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DELIVERIES PROGRESS', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${payout.deliveriesCompleted} deliveries completed', style: AppTextStyles.h3),
            Text('${(payout.weeklyGoalPercent * 100).toStringAsFixed(0)}%', style: AppTextStyles.body.copyWith(color: AppColors.accent)),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: payout.weeklyGoalPercent, minHeight: 10, borderRadius: BorderRadius.circular(99), color: AppColors.accent, backgroundColor: AppColors.accentSoft),
        ])),
        const SizedBox(height: AppSpacing.xl),
        Row(children: [
          const Expanded(child: SectionLabel('Recent Transactions')),
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV export is being prepared.'))),
            icon: const Icon(Icons.download_outlined), label: const Text('Export CSV'),
          ),
        ]),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: payout.transactions.map((tx) => ListTile(
            leading: const CircleAvatar(backgroundColor: AppColors.successBg, child: Icon(Icons.account_balance, color: AppColors.success)),
            title: Text(tx.bankName, style: AppTextStyles.h3),
            subtitle: Text('${DateFormat('MMM d, yyyy').format(tx.dateTime)} · •••• ${tx.accountLastFour}', style: AppTextStyles.caption),
            trailing: Text('\$${tx.amount.toStringAsFixed(2)}', style: AppTextStyles.amountSm),
          )).toList()),
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
}
