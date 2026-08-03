import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

/// How often the dashboard silently re-polls orders for live updates.
const _liveOrdersPollInterval = Duration(seconds: 8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().load();
      if (!context.read<StoreProvider>().storePending) {
        context.read<OrdersProvider>().load();
      }
    });
    // Live order updates while the dashboard is open; pull-to-refresh still
    // works independently. Cancelled in dispose to avoid leaking timers.
    _pollTimer = Timer.periodic(_liveOrdersPollInterval, (_) {
      if (!mounted) return;
      if (!context.read<StoreProvider>().storePending) {
        context.read<OrdersProvider>().refreshSilently();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final store = context.watch<StoreProvider>();
    final orders = context.watch<OrdersProvider>();
    final summary = store.revenueSummary;
    final name = auth.user?.name ?? 'Merchant';
    final rating = (summary['rating'] as num?)?.toDouble() ?? 0;
    final reviewCount = (summary['reviewCount'] as num?)?.toInt() ?? 0;
    final growth = (summary['growthPercent'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: HillGoAppBar(
        title: 'HillGo',
        actions: [
          if (store.store != null)
            Row(
              children: [
                Text('Store Status', style: AppTextStyles.caption),
                const SizedBox(width: 6),
                Switch(
                  value: store.store!.isOpen,
                  activeTrackColor: AppColors.success,
                  onChanged: (v) async {
                    final ok = await store.toggleStoreOpen(v);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            store.error ?? 'Could not update store status',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Text(
                  store.store!.isOpen ? 'Open' : 'Closed',
                  style: AppTextStyles.caption.copyWith(
                    color: store.store!.isOpen
                        ? AppColors.success
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
        ],
      ),
      body: store.isLoading && summary.isEmpty
          ? const LoadingView(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  context.read<OrdersProvider>().load(),
                  context.read<StoreProvider>().load(),
                ]);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Sales Summary', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    '${_greeting()}, $name. Here\'s what\'s happening today.',
                    style: AppTextStyles.subtitle,
                  ),
                  if (store.storePending) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top,
                              color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your store is under review. You\'ll be able to sell as soon as HillGo approves your application.',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary, size: 18),
                    label: Text(
                      DateFormat('MMM d, yyyy').format(_selectedDate),
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetricCard(
                    label: 'TODAY\'S SALES',
                    value: '৳${_fmt((summary['todaySales'] as num?) ?? 0)}',
                    valueColor: AppColors.primary,
                    trailing: const _IconBadge(
                      color: Color(0xFFE3F2FD),
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                    ),
                    footer: Row(
                      children: [
                        Icon(
                          growth >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color:
                              growth >= 0 ? AppColors.success : AppColors.error,
                        ),
                        Text(
                          ' ${growth >= 0 ? '+' : ''}$growth% vs last month',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    label: 'ORDERS TODAY',
                    value: '${(summary['todayOrders'] as num?) ?? 0}',
                    trailing: const _IconBadge(
                      color: Color(0xFFFFE0B2),
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.accent,
                    ),
                    footer: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${(summary['orders'] as num?) ?? 0} orders delivered all time',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    label: 'RATING',
                    value: rating > 0 ? rating.toStringAsFixed(1) : '—',
                    trailing: const _IconBadge(
                      color: AppColors.lime,
                      icon: Icons.star,
                      iconColor: AppColors.chartGreen,
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        StarRating(
                            rating: rating, color: AppColors.chartGreen),
                        Text(
                          reviewCount > 0
                              ? 'Based on ${NumberFormat.compact().format(reviewCount)} reviews'
                              : 'No reviews yet',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Revenue Trend', style: AppTextStyles.h3),
                            const Spacer(),
                            Text('Last 7 days', style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: store.revenueTrend.isEmpty ||
                                  store.revenueTrend
                                      .every((v) => v == 0)
                              ? const EmptyView(
                                  message: 'No sales recorded yet.',
                                  icon: Icons.show_chart,
                                )
                              : _MiniChart(values: store.revenueTrend),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Recent Orders', style: AppTextStyles.h3),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/orders'),
                        child: Text(
                          'View All',
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  if (orders.orders
                      .where((o) =>
                          o.status == OrderStatus.preparing ||
                          o.status == OrderStatus.ready ||
                          o.status == OrderStatus.newOrder)
                      .isEmpty)
                    const EmptyView(
                      message: 'No active orders right now.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    ...orders.orders
                        .where((o) =>
                            o.status == OrderStatus.preparing ||
                            o.status == OrderStatus.ready ||
                            o.status == OrderStatus.newOrder)
                        .take(2)
                        .map((o) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AppCard(
                                onTap: () => context.push('/orders/${o.id}'),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: o.status ==
                                              OrderStatus.preparing
                                          ? AppColors.accentSoft
                                          : AppColors.info,
                                      child: Icon(
                                        o.status == OrderStatus.ready
                                            ? Icons.local_shipping_outlined
                                            : Icons.shopping_bag_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(o.displayId,
                                              style: AppTextStyles.bodyBold),
                                          Text(
                                            '${o.itemCount} items • ৳${o.total.toStringAsFixed(2)}',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusDot(status: o.status),
                                  ],
                                ),
                              ),
                            )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grow your store!',
                                style: AppTextStyles.h3
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                'Refresh your branding to stand out to nearby customers.',
                                style: AppTextStyles.body
                                    .copyWith(color: Colors.black87),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    context.push('/store/branding'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.accent,
                                  minimumSize: const Size(140, 36),
                                ),
                                child: const Text('Update Branding'),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.campaign,
                            size: 48, color: Colors.white54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  String _fmt(num n) {
    return NumberFormat('#,##0.00').format(n);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.trailing,
    required this.footer,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget trailing;
  final Widget footer;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTextStyles.h1.copyWith(
                        color: valueColor ?? AppColors.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          footer,
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final preparing = status == OrderStatus.preparing;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: preparing ? AppColors.success : AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          preparing
              ? 'Preparing'
              : status == OrderStatus.ready
                  ? 'Ready'
                  : 'New',
          style: AppTextStyles.caption.copyWith(
            color: preparing ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final labels = [
      for (var i = values.length - 1; i >= 0; i--)
        DateFormat.E().format(today.subtract(Duration(days: i))),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Text(labels[i], style: AppTextStyles.caption);
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
