import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/driver_provider.dart';
import '../../theme/colors.dart';
import '../../services/fare_config.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final e = driver.earnings;
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu')),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                StatusPill(label: driver.isOnline ? 'ONLINE' : 'OFFLINE', online: driver.isOnline),
                Switch.adaptive(
                  value: driver.isOnline,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) async {
                    final ok = await driver.toggleOnline(v);
                    if (!ok && context.mounted && driver.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(driver.error!)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: driver.isLoading && e == null
          ? const LoadingView()
          : driver.error != null && e == null
              ? ErrorView(message: driver.error!, onRetry: driver.loadDashboard)
              : RefreshIndicator(
                  onRefresh: driver.loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      SectionCard(
                        leftAccent: AppColors.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('CURRENT BALANCE', style: AppTextStyles.labelCaps),
                                const Spacer(),
                                TrendBadge(label: '+${e?.weekTrendPercent.toStringAsFixed(0) ?? 0}% vs LW', compact: true),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatTaka((e?.currentBalance ?? 0)),
                              style: AppTextStyles.moneyMd,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (i) {
                                final selected = driver.selectedWeekDay == i;
                                return GestureDetector(
                                  onTap: () => driver.setSelectedWeekDay(i),
                                  child: Text(
                                    days[i],
                                    style: AppTextStyles.labelCaps.copyWith(
                                      color: selected ? AppColors.primary : AppColors.textMuted,
                                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  barGroups: List.generate(7, (i) {
                                    final totals = e?.dailyTotals ?? List.filled(7, 80.0);
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: totals[i],
                                          width: 14,
                                          borderRadius: BorderRadius.circular(6),
                                          color: driver.selectedWeekDay == i
                                              ? AppColors.primary
                                              : AppColors.primary.withValues(alpha: 0.25),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        borderColor: AppColors.primary.withValues(alpha: 0.35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Instant Pay', style: AppTextStyles.title),
                            const SizedBox(height: 6),
                            Text(
                              'Available to cash out immediately to your linked account.',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 14),
                            AccentButton(
                              label: 'Cash Out',
                              icon: Icons.account_balance_wallet_outlined,
                              onPressed: () => _showCashOut(context, driver),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('This Week\'s Breakdown', style: AppTextStyles.titleBlue),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _BreakdownRow(label: 'Base Fare', value: e?.baseFare ?? 0),
                      _BreakdownRow(label: 'Tips', value: e?.tips ?? 0, valueColor: AppColors.tips),
                      _BreakdownRow(label: 'Surge & Bonuses', value: e?.surgeBonuses ?? 0, valueColor: AppColors.surgeGreen),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/earnings/payouts'),
                        child: const Text('View payout summary →'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Recent Trips', style: AppTextStyles.titleBlue),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/activity'),
                            child: Text('View History →', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                          ),
                        ],
                      ),
                      ...driver.history.take(3).map((t) => _TripTile(trip: t)),
                      const SizedBox(height: 12),
                      SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Optimize your route', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Demand is usually highest during evening rush hours (5–8 PM). Stay online to catch more jobs.',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.map, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showCashOut(BuildContext context, DriverProvider driver) {
    final amountCtrl = TextEditingController(
      text: (driver.earnings?.currentBalance ?? 0).toStringAsFixed(0),
    );
    var method = 'bKash';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instant Pay', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(
                    'Request a payout from your current balance (minimum ৳100). '
                    'Payouts are settled after review.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Amount (৳)',
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  Text('Payout method', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'bKash', label: Text('bKash')),
                      ButtonSegment(value: 'Nagad', label: Text('Nagad')),
                      ButtonSegment(value: 'Bank', label: Text('Bank')),
                    ],
                    selected: {method},
                    onSelectionChanged: (s) => setModal(() => method = s.first),
                  ),
                  const SizedBox(height: 16),
                  AccentButton(
                    label: 'Confirm Cash Out',
                    loading: driver.isLoading,
                    onPressed: () async {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      final ok = await driver.cashOut(amount, method);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Cash-out requested — pending review'
                                : (driver.error ?? 'Cash-out failed'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value, this.valueColor});
  final String label;
  final double value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          const Spacer(),
          Text(
            formatTaka(value),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('EEE, h:mm a').format(trip.createdAt);
    String badge = 'COMPLETED';
    Color badgeBg = AppColors.onlineGreen;
    Color badgeFg = Colors.white;
    if (trip.surgeMultiplier > 1) {
      badge = 'SURGE ${trip.surgeMultiplier}X';
      badgeBg = AppColors.orange;
    } else if (trip.isNightRate) {
      badge = 'NIGHT RATE';
      badgeBg = const Color(0xFFE5E7EB);
      badgeFg = AppColors.textSecondary;
    }

    return InkWell(
      onTap: () => context.push('/trip/details/${trip.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(time, style: AppTextStyles.caption),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(badge, style: AppTextStyles.labelCaps.copyWith(color: badgeFg, fontSize: 9)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardBlueTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    trip.isNightRate ? Icons.nightlight_round : Icons.directions_car_filled,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.routeLabel, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${formatKm(trip.distanceKm)} • ${trip.durationMin} min • ${trip.jobType.label}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatTaka(trip.total), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
                    if (trip.note != null)
                      Text(
                        trip.note!,
                        style: AppTextStyles.caption.copyWith(
                          color: trip.tip > 0 ? AppColors.orange : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
