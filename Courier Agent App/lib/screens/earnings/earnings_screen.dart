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

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<EarningsProvider>().loadEarnings(); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HillGoAppBar(showMenu: true, onBell: () => context.push('/notifications')),
    body: Consumer<EarningsProvider>(builder: (context, provider, _) {
      if (provider.state == EarningsLoadState.loading) return const LoadingView(message: 'Loading earnings...');
      if (provider.state == EarningsLoadState.error) return ErrorView(message: provider.error ?? 'Could not load earnings.', onRetry: provider.loadEarnings);
      final weekly = provider.weekly;
      if (weekly == null) return const EmptyView(message: 'Earnings are not available yet.');
      return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        AppCard(color: AppColors.primary, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WEEKLY SUMMARY', style: AppTextStyles.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('৳${weekly.total.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: StatusChip(
                label: '${weekly.percentChange >= 0 ? '+' : ''}${weekly.percentChange.toStringAsFixed(0)}%',
                fg: weekly.percentChange >= 0 ? AppColors.success : AppColors.error,
                bg: weekly.percentChange >= 0 ? AppColors.successBg : AppColors.errorBg,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => context.push('/withdraw'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)), child: const Text('Withdraw Funds'))),
            const SizedBox(width: 10),
            Expanded(child: TextButton(onPressed: () => context.push('/payout'), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Payout History'))),
          ]),
        ])),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Expanded(child: _stat('Total Deliveries', '${weekly.totalDeliveries}', Icons.local_shipping_outlined)),
          const SizedBox(width: 12),
          Expanded(child: _stat('Avg / Delivery', '৳${weekly.avgPerDelivery.toStringAsFixed(2)}', Icons.trending_up_rounded)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WEEKLY GOAL', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${weekly.totalDeliveries} of ${weekly.weeklyGoal} deliveries', style: AppTextStyles.h3),
            Text('${weekly.weeklyGoalPercent.toStringAsFixed(0)}%', style: AppTextStyles.body.copyWith(color: AppColors.accent)),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: (weekly.weeklyGoalPercent / 100).clamp(0.0, 1.0), minHeight: 10, borderRadius: BorderRadius.circular(99), color: AppColors.accent, backgroundColor: AppColors.accentSoft),
        ])),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Daily Breakdown'),
        const SizedBox(height: AppSpacing.sm),
        if (provider.daily.isEmpty)
          const Padding(padding: EdgeInsets.all(30), child: EmptyView(message: 'No daily breakdown is available.'))
        else
          ...List.generate(provider.daily.length, (index) => _dayRow(provider.daily[index], index, provider)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(child: Text('Missing earnings? Completed deliveries can take up to 24 hours to appear.', style: AppTextStyles.bodySecondary)),
          ]),
        ),
      ]);
    }),
  );

  Widget _stat(String label, String value, IconData icon) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.accent), const SizedBox(height: 12),
    Text(label, style: AppTextStyles.caption), Text(value, style: AppTextStyles.amountSm),
  ]));

  Widget _dayRow(DailyEarning day, int index, EarningsProvider provider) {
    final expanded = provider.expandedDays.contains(index);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Column(children: [
        ListTile(
          onTap: () => provider.toggleDay(index),
          title: Text(DateFormat('EEEE, MMM d').format(day.date), style: AppTextStyles.h3),
          subtitle: Text('${day.deliveries} deliveries', style: AppTextStyles.caption),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('৳${day.total.toStringAsFixed(2)}', style: AppTextStyles.amountSm),
            Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ]),
        ),
        if (expanded) Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(children: [
            _line('Base pay', day.basePay), _line('Surges', day.surges),
          ]),
        ),
      ]),
    );
  }
  Widget _line(String label, double amount) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.bodySecondary), Text('৳${amount.toStringAsFixed(2)}', style: AppTextStyles.body)]),
  );
}
