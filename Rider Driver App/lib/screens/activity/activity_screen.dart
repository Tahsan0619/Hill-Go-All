import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/driver_provider.dart';
import '../../theme/colors.dart';
import '../../services/fare_config.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().refreshHistory();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Activity')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: driver.setHistoryQuery,
              decoration: InputDecoration(
                hintText: 'Search trips, riders, areas…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          driver.setHistoryQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: driver.historyFilter == 'all',
                  onTap: () => driver.setHistoryFilter('all'),
                ),
                _FilterChip(
                  label: 'Completed',
                  selected: driver.historyFilter == 'completed',
                  onTap: () => driver.setHistoryFilter('completed'),
                ),
                _FilterChip(
                  label: 'COD',
                  selected: driver.historyFilter == 'cod',
                  onTap: () => driver.setHistoryFilter('cod'),
                ),
                _FilterChip(
                  label: 'Cancelled',
                  selected: driver.historyFilter == 'cancelled',
                  onTap: () => driver.setHistoryFilter('cancelled'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: driver.isLoading && driver.history.isEmpty
                ? const LoadingView()
                : driver.error != null && driver.history.isEmpty
                    ? ErrorView(message: driver.error!, onRetry: driver.refreshHistory)
                    : driver.history.isEmpty
                        ? const EmptyView(
                            title: 'No trips found',
                            subtitle: 'Try another filter or go online to start earning.',
                            icon: Icons.route_outlined,
                          )
                        : RefreshIndicator(
                            onRefresh: driver.refreshHistory,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: driver.history.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final trip = driver.history[i];
                                return _HistoryCard(trip: trip);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: AppTextStyles.label.copyWith(
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: InkWell(
        onTap: () => context.push('/trip/details/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(DateFormat('MMM d • h:mm a').format(trip.createdAt), style: AppTextStyles.caption),
                const Spacer(),
                Text(
                  formatTaka(trip.total),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trip.routeLabel, style: AppTextStyles.title.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '${formatKm(trip.distanceKm)} • ${trip.durationMin} min • ${trip.customerName}',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: trip.status == TripStatus.completed ? AppColors.onlineGreen : AppColors.orange),
                const SizedBox(width: 6),
                Text(trip.status.name.toUpperCase(), style: AppTextStyles.labelCaps.copyWith(fontSize: 10)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
