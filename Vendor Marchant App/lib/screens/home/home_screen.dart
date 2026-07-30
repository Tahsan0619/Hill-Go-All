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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _trendRange = 'Last 7 Days';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
      context.read<StoreProvider>().load();
    });
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
                  onChanged: (v) => store.toggleStoreOpen(v),
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
                    '$_greeting(), $name. Here\'s what\'s happening today.',
                    style: AppTextStyles.subtitle,
                  ),
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
                    label: 'TOTAL SALES',
                    value:
                        '\$${_fmt(summary['todaySales'] as num? ?? 12840.50)}',
                    valueColor: AppColors.primary,
                    trailing: _IconBadge(
                      color: const Color(0xFFE3F2FD),
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                    ),
                    footer: Row(
                      children: [
                        const Icon(Icons.arrow_upward,
                            size: 14, color: AppColors.success),
                        Text(
                          ' +${summary['growthPercent'] ?? 12.5}% from yesterday',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    label: 'ORDERS',
                    value: '${summary['todayOrders'] ?? 148}',
                    trailing: _IconBadge(
                      color: const Color(0xFFFFE0B2),
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.accent,
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.75,
                            minHeight: 6,
                            backgroundColor: Color(0xFFECECEC),
                            color: Color(0xFFBF6A3A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('75% of daily target', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    label: 'RATING',
                    value: '${summary['rating'] ?? 4.8}',
                    trailing: _IconBadge(
                      color: AppColors.lime,
                      icon: Icons.star,
                      iconColor: AppColors.chartGreen,
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const StarRating(rating: 4.8, color: AppColors.chartGreen),
                        Text(
                          'Based on ${NumberFormat.compact().format(summary['reviewCount'] ?? 1284)} reviews',
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
                            PopupMenuButton<String>(
                              initialValue: _trendRange,
                              onSelected: (v) =>
                                  setState(() => _trendRange = v),
                              itemBuilder: (_) => [
                                'Last 7 Days',
                                'Last 30 Days',
                                'This Month',
                              ]
                                  .map((e) => PopupMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(_trendRange,
                                        style: AppTextStyles.caption),
                                    const Icon(Icons.arrow_drop_down, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: _MiniChart(
                            values: store.revenueTrend.isEmpty
                                ? const [1.8, 2.2, 1.9, 2.4, 2.1, 2.8, 2.6]
                                : store.revenueTrend
                                    .map((e) => e / 1000)
                                    .toList(),
                          ),
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
                                        Text('#${o.id}',
                                            style: AppTextStyles.bodyBold),
                                        Text(
                                          '${o.itemCount} items • \$${o.total.toStringAsFixed(2)}',
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
                                'Boost Sales!',
                                style: AppTextStyles.h3
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                'Run a flash sale today and reach 5k+ nearby customers.',
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
                                child: const Text('Start Campaign'),
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
                  ? 'On the way'
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Text(days[i], style: AppTextStyles.caption);
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
