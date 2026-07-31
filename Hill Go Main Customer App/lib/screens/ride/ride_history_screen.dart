import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/status_badge.dart';
import 'ride_details_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  static const String routeName = '/ride/history';

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  late Future<List<RideEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = RidesApi.list();
  }

  void _reload() {
    setState(() => _future = RidesApi.list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Ride history'),
      body: FutureBuilder<List<RideEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return LoadErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final rides = snapshot.data ?? const <RideEntry>[];
          if (rides.isEmpty) {
            return const EmptyView(
              icon: Icons.directions_car_outlined,
              message: 'No rides yet. Book your first ride from the home screen.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _RideHistoryTile(
                  ride: ride,
                  onTap: () => Navigator.of(context).pushNamed(
                    RideDetailsScreen.routeName,
                    arguments: ride,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RideHistoryTile extends StatelessWidget {
  const _RideHistoryTile({required this.ride, required this.onTap});

  final RideEntry ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = ride.status == 'completed';
    final isCancelled = ride.status == 'cancelled';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isCancelled ? AppColors.accentOrangeSoft : AppColors.accentBlueSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCancelled ? Icons.close_rounded : Icons.directions_car,
                color: isCancelled ? AppColors.accentOrange : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.pickup} → ${ride.drop}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(ride.dateLabel, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${ride.fare.toStringAsFixed(0)}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: statusLabel(ride.status),
                  color: isCompleted
                      ? AppColors.brandLime
                      : isCancelled
                          ? Colors.red
                          : AppColors.accentOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
