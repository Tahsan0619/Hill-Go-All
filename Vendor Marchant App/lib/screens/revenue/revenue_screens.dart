import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/store_model.dart';
import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<StoreProvider>();
      if (s.revenueSummary.isEmpty) s.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final s = store.revenueSummary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: store.isLoading && s.isEmpty
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.payments_outlined,
                          size: 64,
                          color: AppColors.cardBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Revenue', style: AppTextStyles.label),
                          Text(
                            '\$${NumberFormat('#,##0.00').format(s['totalRevenue'] ?? 42850.20)}',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.primary),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.trending_up,
                                  size: 16, color: AppColors.success),
                              Text(
                                ' +${s['growthPercent'] ?? 12.5}% from last month',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pending Payout', style: AppTextStyles.label),
                            Text(
                              '\$${NumberFormat('#,##0.00').format(s['pendingPayout'] ?? 3240)}',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.primary),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    size: 8, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text('Est. Tuesday',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.accent)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Orders', style: AppTextStyles.label),
                            Text(
                              '${s['orders'] ?? 1204}',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.primary),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('Active today',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Revenue Trends', style: AppTextStyles.h3),
                Text('Weekly performance analysis',
                    style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: ['Daily', 'Weekly', 'Monthly'].map((p) {
                      final active = store.trendPeriod == p;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => store.setTrendPeriod(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p,
                              style: AppTextStyles.bodyBold.copyWith(
                                color: active
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: SizedBox(
                    height: 180,
                    child: store.revenueTrend.isEmpty
                        ? const LoadingView()
                        : BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const labels = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun'
                                      ];
                                      final i = v.toInt();
                                      if (i < 0 || i >= labels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(labels[i],
                                          style: AppTextStyles.caption);
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0;
                                    i < store.revenueTrend.length;
                                    i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: store.revenueTrend[i] /
                                            (store.trendPeriod == 'Monthly'
                                                ? 1000
                                                : 100),
                                        color: AppColors.primary,
                                        width: 14,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Recent Transactions', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/store/payouts'),
                      child: Text(
                        'View All',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                ...store.transactions.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: t.type == TransactionType.order
                                  ? AppColors.info
                                  : AppColors.accentSoft,
                              child: Icon(
                                t.type == TransactionType.order
                                    ? Icons.shopping_cart_outlined
                                    : Icons.account_balance_wallet_outlined,
                                color: t.type == TransactionType.order
                                    ? AppColors.primary
                                    : AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title, style: AppTextStyles.bodyBold),
                                  Text(t.subtitle, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${t.amount >= 0 ? '+' : ''}\$${t.amount.abs().toStringAsFixed(2)}',
                                  style: AppTextStyles.bodyBold,
                                ),
                                Text(
                                  t.statusLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    color: t.statusLabel == 'Completed'
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Payout: Oct 24',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Your automatic payout of \$${NumberFormat('#,##0.00').format(s['pendingPayout'] ?? 3240)} is scheduled for next Tuesday.',
                        style:
                            AppTextStyles.body.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: store.isSaving
                            ? null
                            : () async {
                                final ok = await store.requestEarlyPayout();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? 'Early payout requested'
                                            : 'Request failed',
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: store.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Request Early Payout'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<StoreProvider>();
      if (s.payouts.isEmpty) s.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final list = store.filteredPayouts;
    final last = store.payouts.isNotEmpty
        ? store.payouts
            .where((p) => p.status == PayoutStatus.completed)
            .fold<DateTime?>(
              null,
              (prev, p) =>
                  prev == null || p.date.isAfter(prev) ? p.date : prev,
            )
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: store.isLoading && store.payouts.isEmpty
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL WITHDRAWN',
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white70),
                      ),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(store.totalWithdrawn)}',
                        style: AppTextStyles.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Payout Date',
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white70),
                                ),
                                Text(
                                  last != null
                                      ? DateFormat('MMM d, yyyy').format(last)
                                      : '—',
                                  style: AppTextStyles.bodyBold
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Payout History', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Completed only'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Filter applied: Completed (use chips for date range)',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  title: const Text('Pending only'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Filter applied: Pending (use chips for date range)',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune, size: 18),
                      label: Text(
                        'Filter',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                FilterChipBar(
                  items: const ['All Time', 'Last 30 Days', 'Last 3 Months'],
                  selected: store.payoutFilter,
                  activeColor: AppColors.accent,
                  onSelected: store.setPayoutFilter,
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const EmptyView(message: 'No payouts in this period.')
                else
                  ...list.map((p) {
                    final completed = p.status == PayoutStatus.completed;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: completed
                                  ? AppColors.successSoft
                                  : AppColors.warningSoft,
                              child: Icon(
                                completed ? Icons.check : Icons.more_horiz,
                                color: completed
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${p.amount.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyBold,
                                  ),
                                  Text(
                                    'Ref: #${p.id}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: completed
                                        ? AppColors.successSoft
                                        : AppColors.warningSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    completed ? 'Completed' : 'Pending',
                                    style: AppTextStyles.caption.copyWith(
                                      color: completed
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, yyyy').format(p.date),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
