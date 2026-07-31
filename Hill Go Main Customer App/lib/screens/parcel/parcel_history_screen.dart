import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/parcels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';
import 'parcel_tracking_screen.dart';

class ParcelHistoryScreen extends StatefulWidget {
  const ParcelHistoryScreen({super.key});

  static const String routeName = '/parcel/history';

  @override
  State<ParcelHistoryScreen> createState() => _ParcelHistoryScreenState();
}

class _ParcelHistoryScreenState extends State<ParcelHistoryScreen> {
  late Future<List<ParcelEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ParcelsApi.list();
  }

  void _reload() {
    setState(() => _future = ParcelsApi.list());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF2E9E44);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(title: 'Parcel History'),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<ParcelEntry>>(
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
                    final rows = snapshot.data ?? const <ParcelEntry>[];
                    if (rows.isEmpty) {
                      return const EmptyView(
                        icon: Icons.inventory_2_outlined,
                        message: 'No parcels yet.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = rows[index];
                          final statusColor = _statusColor(entry.status);
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ParcelTrackingScreen(parcel: entry),
                                ),
                              );
                            },
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
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF1FB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 22,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.type} to ${entry.dropAddress}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${entry.code} · ${entry.dateLabel}',
                                          style: textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      statusLabel(entry.status),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
