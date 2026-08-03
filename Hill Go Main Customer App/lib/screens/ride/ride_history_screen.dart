import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/user_facing_error.dart';
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
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<RideEntry> _rides = [];
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final page = reset ? 1 : _page + 1;
      final result = await RidesApi.list(page: page);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _rides = result.items;
        } else {
          _rides = [..._rides, ...result.items];
        }
        _page = result.page;
        _hasMore = result.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    await _load(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Ride history'),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? LoadErrorView(
                  message: _error!,
                  onRetry: () => _load(reset: true),
                )
              : _rides.isEmpty
                  ? const EmptyView(
                      icon: Icons.directions_car_outlined,
                      message:
                          'No rides yet. Book your first ride from the home screen.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _rides.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= _rides.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: _loadingMore
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : TextButton(
                                        onPressed: _loadMore,
                                        child: const Text('Load more'),
                                      ),
                              ),
                            );
                          }
                          final ride = _rides[index];
                          return _RideHistoryTile(
                            ride: ride,
                            onTap: () => Navigator.of(context).pushNamed(
                              RideDetailsScreen.routeName,
                              arguments: ride,
                            ),
                          );
                        },
                      ),
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
