import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/parcels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';

class ParcelTrackingScreen extends StatefulWidget {
  const ParcelTrackingScreen({super.key, this.parcel});

  static const String routeName = '/parcel/tracking';

  final ParcelEntry? parcel;

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  static const _steps = [
    ('booked', 'Booked', 'Your parcel booking has been confirmed', Icons.check_circle_outline),
    ('picked_up', 'Picked Up', 'Rider collected the parcel from sender', Icons.inventory_2_outlined),
    ('in_transit', 'In Transit', 'Parcel is on the way to destination', Icons.local_shipping_outlined),
    ('delivered', 'Delivered', 'Parcel delivered to the receiver', Icons.home_outlined),
  ];

  ParcelEntry? _parcel;
  Timer? _pollTimer;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    _parcel = widget.parcel ?? (args is ParcelEntry ? args : null);
    final parcel = _parcel;
    if (parcel != null &&
        parcel.status != 'delivered' &&
        parcel.status != 'cancelled') {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    }
  }

  Future<void> _poll() async {
    final parcel = _parcel;
    if (parcel == null) return;
    try {
      final fresh = await ParcelsApi.show(parcel.id);
      if (!mounted) return;
      setState(() => _parcel = fresh);
      if (fresh.status == 'delivered' || fresh.status == 'cancelled') {
        _pollTimer?.cancel();
      }
    } on ApiException {
      // Ignore transient polling failures; retried on the next tick.
    }
  }

  int get _currentStep {
    final status = _parcel?.status;
    if (status == 'cancelled') return -1;
    final index = _steps.indexWhere((step) => step.$1 == status);
    return index == -1 ? 0 : index;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parcel = _parcel;

    if (parcel == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                const AppBackBar(title: 'Track Parcel'),
                const Spacer(),
                Text('Parcel not found.', style: textTheme.bodyLarge),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final isCancelled = parcel.status == 'cancelled';
    final currentStep = _currentStep;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(title: 'Track Parcel', subtitle: parcel.code),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.accentBlueSoft,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 56,
                                color: AppColors.primaryNavy,
                              ),
                              Positioned(
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isCancelled
                                        ? 'Cancelled'
                                        : statusLabel(parcel.status),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${parcel.type} → ${parcel.dropAddress}',
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fare ৳${parcel.fare.toStringAsFixed(0)} • ${statusLabel(parcel.paymentMethod)}',
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      if (parcel.pickupOtp != null || parcel.deliveryOtp != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrangeSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            [
                              if (parcel.pickupOtp != null) 'Pickup OTP: ${parcel.pickupOtp}',
                              if (parcel.deliveryOtp != null) 'Delivery OTP: ${parcel.deliveryOtp}',
                            ].join(' · '),
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      if (parcel.agentName != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Courier: ${parcel.agentName}${parcel.agentPhone != null ? ' · ${parcel.agentPhone}' : ''}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Delivery status',
                        style: textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (isCancelled)
                        Text(
                          'This parcel was cancelled.',
                          style: textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
                        )
                      else
                        Column(
                          children: List.generate(_steps.length, (index) {
                            final (_, title, description, icon) = _steps[index];
                            final isCompleted = index <= currentStep;
                            final isLast = index == _steps.length - 1;
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.primaryNavy
                                              : AppColors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCompleted
                                                ? AppColors.primaryNavy
                                                : AppColors.cardBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 18,
                                          color: isCompleted
                                              ? AppColors.white
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: isCompleted
                                                ? AppColors.primaryNavy
                                                : AppColors.cardBorder,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: textTheme.bodyLarge?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(description, style: textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
