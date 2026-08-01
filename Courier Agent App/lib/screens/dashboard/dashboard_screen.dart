import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/parcel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parcel_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_map.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Rangamati, the heart of HillGo's coverage area — used until a parcel
  // provides real coordinates.
  static const _fallbackCenter = LatLng(22.6533, 92.1789);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      final provider = context.read<ParcelProvider>();
      if (user != null) provider.syncOnline(user.online);
      provider.loadDashboard();
    });
  }

  Future<void> _toggleOnline(bool value) async {
    final provider = context.read<ParcelProvider>();
    final message = await provider.setOnline(value);
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HillGoAppBar(showMenu: true, onBell: () => context.push('/notifications')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.go('/earnings'),
        child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
      ),
      body: Consumer<ParcelProvider>(
        builder: (context, provider, _) {
          if (provider.assignedState == LoadState.loading) return const LoadingView(message: 'Loading your dashboard...');
          if (provider.assignedState == LoadState.error) {
            return ErrorView(message: provider.error ?? 'Could not load dashboard.', onRetry: provider.loadDashboard);
          }
          final stats = provider.dashboardStats;
          if (stats == null) return const EmptyView(message: 'No dashboard information available.');
          final firstWithCoords = provider.assigned.where((p) => p.hasCoordinates).toList();
          final mapCenter = firstWithCoords.isEmpty ? _fallbackCenter : firstWithCoords.first.pickup;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              AppCard(
                color: AppColors.primary,
                child: Row(children: [
                  Icon(Icons.circle, size: 12, color: provider.isOnline ? const Color(0xFF7CFF9A) : Colors.white38),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CURRENT STATUS', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                    Text(provider.isOnline ? 'Active Now' : 'Offline', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                  ])),
                  Switch(
                    value: provider.isOnline,
                    onChanged: provider.presenceUpdating ? null : _toggleOnline,
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(child: _statCard('Today\'s Earnings', '৳${stats.todayEarnings.toStringAsFixed(2)}', Icons.payments_outlined)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _statCard('Distance Traveled', '${stats.distanceKm.toStringAsFixed(1)} km', Icons.route_outlined)),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Stack(children: [
                AppMapView(
                  center: mapCenter,
                  height: 220,
                  markers: [
                    for (final parcel in firstWithCoords)
                      pinMarker(parcel.pickup, color: AppColors.primary, icon: Icons.inventory_2_outlined),
                  ],
                ),
                Positioned(top: 12, left: 12, child: StatusChip(label: 'LIVE AREA', fg: AppColors.primary, bg: Colors.white)),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const SectionLabel('Assigned Parcels'),
              const SizedBox(height: AppSpacing.sm),
              if (provider.assigned.isEmpty)
                const SizedBox(height: 160, child: EmptyView(message: 'No parcels assigned right now.', icon: Icons.inventory_2_outlined))
              else
                ...provider.assigned.map((parcel) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _parcelCard(parcel),
                )),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                color: AppColors.primaryDark,
                child: Row(children: [
                  const CircleAvatar(backgroundColor: AppColors.accent, child: Icon(Icons.local_shipping_outlined, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Deliveries Today', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                    Text('${stats.deliveriesToday}', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                  ])),
                  Text('${stats.bonusMultiplier.toStringAsFixed(1)}x bonus', style: AppTextStyles.caption.copyWith(color: const Color(0xFFFFCE9F))),
                ]),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(children: [
                const Expanded(child: SectionLabel('Earnings Trend')),
                TextButton(onPressed: () => context.go('/earnings'), child: const Text('View earnings')),
              ]),
              SizedBox(height: 180, child: _trendChart(stats.earningsTrend, stats.trendLabels)),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) => AppCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.accent),
      const SizedBox(height: 12),
      Text(label, style: AppTextStyles.caption),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.amountSm),
    ]),
  );

  Widget _parcelCard(ParcelModel p) => AppCard(
    onTap: () => context.push('/parcel/${p.id}'),
    child: Row(children: [
      CircleAvatar(backgroundColor: AppColors.accentSoft, child: const Icon(Icons.inventory_2_outlined, color: AppColors.accent)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.orderId, style: AppTextStyles.h3),
        const SizedBox(height: 3),
        Text('${p.senderAddress} → ${p.receiverAddress}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text('৳${p.estimatedEarnings.toStringAsFixed(2)} · ${p.etaMinutes} min', style: AppTextStyles.bodySecondary),
      ])),
      StatusChip(label: p.priority.name.toUpperCase(), fg: AppColors.accent, bg: AppColors.accentSoft),
    ]),
  );

  Widget _trendChart(List<double> values, List<String> labels) {
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          return Padding(padding: const EdgeInsets.only(top: 8), child: Text(i < labels.length ? labels[i] : '', style: AppTextStyles.caption));
        })),
      ),
      barGroups: List.generate(values.length, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: values[i], width: 16, color: i == values.length - 1 ? AppColors.accent : AppColors.primary, borderRadius: BorderRadius.circular(4)),
      ])),
    ));
  }
}
