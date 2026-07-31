import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';
import '../sos/sos_screen.dart';
import 'ride_details_screen.dart';

class LiveRideTrackingScreen extends StatefulWidget {
  const LiveRideTrackingScreen({super.key});

  static const String routeName = '/ride/tracking';

  @override
  State<LiveRideTrackingScreen> createState() => _LiveRideTrackingScreenState();
}

class _LiveRideTrackingScreenState extends State<LiveRideTrackingScreen> {
  RideEntry? _ride;
  Timer? _pollTimer;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is RideEntry) {
      _ride = args;
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      unawaited(_poll());
    }
  }

  Future<void> _poll() async {
    final ride = _ride;
    if (ride == null) return;
    try {
      final fresh = await RidesApi.show(ride.id);
      if (!mounted) return;
      if (fresh.status == 'completed') {
        _pollTimer?.cancel();
        Navigator.of(context).pushReplacementNamed(
          RideDetailsScreen.routeName,
          arguments: fresh,
        );
        return;
      }
      if (fresh.status == 'cancelled') {
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The ride was cancelled.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      setState(() => _ride = fresh);
    } on ApiException {
      // Ignore transient polling failures; retried on the next tick.
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = _ride;
    final textTheme = Theme.of(context).textTheme;

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Live tracking')),
        body: Center(child: Text('Ride not found.', style: textTheme.bodyLarge)),
      );
    }

    final driverName = ride.driver?.name ?? 'your driver';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const MapPlaceholder(showRoute: true),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          SosScreen.routeName,
                          arguments: 'Ride SOS',
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.sos, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: AppColors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${statusLabel(ride.status)} • $driverName • '
                          '~${ride.durationMin.round()} min trip',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppColors.primaryNavy, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ride.pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.accentOrange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ride.drop,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _snack('Trip link copied to share'),
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share trip'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryNavy,
                            side: const BorderSide(color: AppColors.primaryNavy),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fare ৳${ride.fare.toStringAsFixed(0)} • ${statusLabel(ride.paymentMethod)}',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
