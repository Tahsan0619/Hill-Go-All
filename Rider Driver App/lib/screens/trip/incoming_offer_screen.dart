import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/driver_provider.dart';
import '../../services/fare_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/hillgo_map.dart';

class IncomingOfferScreen extends StatefulWidget {
  const IncomingOfferScreen({super.key});

  @override
  State<IncomingOfferScreen> createState() => _IncomingOfferScreenState();
}

class _IncomingOfferScreenState extends State<IncomingOfferScreen> {
  static const _acceptSeconds = 30;
  Timer? _timer;
  int _remaining = _acceptSeconds;
  String? _offerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimerIfNeeded());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    final offer = context.read<DriverProvider>().incomingOffer;
    if (offer == null) return;
    if (_offerId == offer.id && _timer != null) return;
    _offerId = offer.id;
    _remaining = _acceptSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
        final driver = context.read<DriverProvider>();
        await driver.declineOffer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offer expired')),
          );
          context.go('/home');
        }
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  Color _typeColor(JobType type) => switch (type) {
        JobType.ride => AppColors.primary,
        JobType.food => AppColors.orange,
        JobType.parcel => AppColors.success,
      };

  IconData _typeIcon(JobType type) => switch (type) {
        JobType.ride => Icons.directions_car,
        JobType.food => Icons.restaurant,
        JobType.parcel => Icons.inventory_2_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final offer = driver.incomingOffer;

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Offer')),
        body: const EmptyView(
          title: 'No active offer',
          subtitle: 'Go online on Home to receive Ride / Food / Parcel jobs.',
          icon: Icons.work_outline,
        ),
      );
    }

    if (_offerId != offer.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTimerIfNeeded());
    }

    final pickup = LatLng(offer.pickupLat, offer.pickupLng);
    final dropoff = LatLng(offer.dropoffLat, offer.dropoffLng);
    final progress = _remaining / _acceptSeconds;

    return Scaffold(
      body: Stack(
        children: [
          HillGoMap(
            center: LatLng(
              (offer.pickupLat + offer.dropoffLat) / 2,
              (offer.pickupLng + offer.dropoffLng) / 2,
            ),
            zoom: 12.8,
            markers: [
              HillGoMap.destinationMarker(pickup, isDropoff: false),
              HillGoMap.destinationMarker(dropoff, isDropoff: true),
            ],
            polylines: [
              Polyline(
                points: [pickup, dropoff],
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => context.go('/home'),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Accept in ${_remaining}s',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _remaining <= 10 ? AppColors.tips : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white54,
                      color: _remaining <= 10 ? AppColors.tips : AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _typeColor(offer.jobType).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_typeIcon(offer.jobType), size: 16, color: _typeColor(offer.jobType)),
                                      const SizedBox(width: 6),
                                      Text(
                                        offer.jobType.label.toUpperCase(),
                                        style: AppTextStyles.labelCaps.copyWith(
                                          color: _typeColor(offer.jobType),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                if (offer.vehicleRequired != null)
                                  Text(
                                    offer.vehicleRequired!.label,
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'JOB FARE',
                                        style: AppTextStyles.labelCaps.copyWith(fontSize: 10),
                                      ),
                                      Text(
                                        formatTaka(offer.earning),
                                        style: AppTextStyles.moneyMd.copyWith(fontSize: 30),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ETA', style: AppTextStyles.caption),
                                    Text(
                                      '${offer.durationMin} min',
                                      style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (offer.isCod)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  offer.note ?? 'COD — collect ${formatTaka(offer.earning)} cash',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.orangeDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _StopRow(
                                  color: AppColors.primary,
                                  label: offer.jobType.pickupLabel.toUpperCase(),
                                  title: offer.pickupName,
                                  subtitle: offer.pickupAddress,
                                  isPickup: true,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 11),
                                  alignment: Alignment.centerLeft,
                                  height: 18,
                                  width: 2,
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                ),
                                _StopRow(
                                  color: AppColors.orange,
                                  label: offer.jobType.dropLabel.toUpperCase(),
                                  title: offer.dropoffName,
                                  subtitle: offer.dropoffAddress,
                                  isPickup: false,
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('DISTANCE', style: AppTextStyles.labelCaps.copyWith(fontSize: 10)),
                                          Text(
                                            formatKm(offer.distanceKm),
                                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 1, height: 36, color: AppColors.divider),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            offer.jobType == JobType.parcel ? 'PACKAGE' : 'DURATION',
                                            style: AppTextStyles.labelCaps.copyWith(fontSize: 10),
                                          ),
                                          Text(
                                            offer.jobType == JobType.parcel
                                                ? (offer.packageLabel ?? '${offer.weightKg ?? 1} kg')
                                                : '${offer.durationMin} min',
                                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: driver.isLoading
                                  ? null
                                  : () async {
                                      _timer?.cancel();
                                      await driver.declineOffer();
                                      if (context.mounted) context.go('/home');
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFFECACA),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                              ),
                              child: Text(
                                'DECLINE',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: AccentButton(
                            label: 'ACCEPT',
                            icon: Icons.check,
                            loading: driver.isLoading,
                            onPressed: () async {
                              _timer?.cancel();
                              final ok = await driver.acceptOffer();
                              if (!context.mounted) return;
                              if (ok) {
                                context.go('/trip/navigation');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(driver.error ?? 'Could not accept')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.color,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.isPickup,
  });

  final Color color;
  final String label;
  final String title;
  final String subtitle;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isPickup ? Icons.circle : Icons.location_on, size: 22, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelCaps.copyWith(fontSize: 10)),
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
