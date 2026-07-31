import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/hotels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/status_badge.dart';

class HotelBookingsScreen extends StatefulWidget {
  const HotelBookingsScreen({super.key});

  static const String routeName = '/hotel/bookings';

  @override
  State<HotelBookingsScreen> createState() => _HotelBookingsScreenState();
}

class _HotelBookingsScreenState extends State<HotelBookingsScreen> {
  late Future<List<HotelBookingEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = HotelsApi.bookings();
  }

  void _reload() {
    setState(() => _future = HotelsApi.bookings());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'My hotel bookings',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<HotelBookingEntry>>(
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
          final rows = snapshot.data ?? const <HotelBookingEntry>[];
          if (rows.isEmpty) {
            return const EmptyView(
              icon: Icons.hotel_outlined,
              message: 'No hotel bookings yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = rows[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.hotelName,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: entry.status,
                            color: entry.status == 'Upcoming'
                                ? AppColors.accentOrange
                                : AppColors.primaryNavy,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(entry.location, style: textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(entry.datesLabel, style: textTheme.bodyMedium),
                          const Spacer(),
                          Text(
                            '৳${entry.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.bookingId,
                        style: textTheme.bodySmall,
                      ),
                    ],
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
