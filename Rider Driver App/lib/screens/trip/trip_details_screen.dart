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

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  Trip? _trip;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trip = await context.read<DriverProvider>().getTrip(widget.tripId);
      setState(() {
        _trip = trip;
        _loading = false;
        if (trip == null) _error = 'Trip not found';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _trip == null
                  ? const EmptyView(title: 'Trip missing', subtitle: 'This trip could not be loaded.')
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        SectionCard(
                          leftAccent: AppColors.primary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMM d • h:mm a').format(_trip!.createdAt),
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 8),
                              Text(_trip!.routeLabel, style: AppTextStyles.headline.copyWith(fontSize: 20)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _trip!.status.name.toUpperCase(),
                                  style: AppTextStyles.labelCaps.copyWith(color: AppColors.success, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SectionCard(
                          child: Column(
                            children: [
                              _line('Pickup', _trip!.pickupName, _trip!.pickupAddress),
                              const Divider(height: 24),
                              _line('Drop-off', _trip!.dropoffName, _trip!.dropoffAddress),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SectionCard(
                          child: Column(
                            children: [
                              _kv('Distance', formatKm(_trip!.distanceKm)),
                              _kv('Duration', '${_trip!.durationMin} min'),
                              _kv('Type', _trip!.jobType.label),
                              if (_trip!.packageLabel != null)
                                _kv('Package', _trip!.packageLabel!),
                              _kv('Customer', '${_trip!.customerName} (${_trip!.customerRating}★)'),
                              _kv('Base earning', formatTaka(_trip!.earning)),
                              _kv('Tip', formatTaka(_trip!.tip)),
                              if (_trip!.isCod) _kv('Payment', 'COD'),
                              const Divider(height: 20),
                              _kv('Total', formatTaka(_trip!.total), bold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Email support@hillgo.com with the trip code to report an issue.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Report an issue'),
                        ),
                      ],
                    ),
    );
  }

  Widget _line(String label, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          label == 'Pickup' ? Icons.circle : Icons.location_on,
          color: label == 'Pickup' ? AppColors.primary : AppColors.orange,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppTextStyles.labelCaps.copyWith(fontSize: 10)),
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(k, style: AppTextStyles.bodySecondary),
          const Spacer(),
          Text(v, style: AppTextStyles.body.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
