import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';
import '../sos/sos_screen.dart';
import 'live_ride_tracking_screen.dart';

class DriverAssignedScreen extends StatefulWidget {
  const DriverAssignedScreen({super.key});

  static const String routeName = '/ride/assigned';

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen> {
  RideEntry? _ride;
  Timer? _pollTimer;
  bool _cancelling = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is RideEntry) {
      _ride = args;
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
      unawaited(_poll());
    }
  }

  Future<void> _poll() async {
    final ride = _ride;
    if (ride == null || _cancelling) return;
    try {
      final fresh = await RidesApi.show(ride.id);
      if (!mounted) return;
      if (fresh.status == 'ongoing' || fresh.status == 'in_progress') {
        _pollTimer?.cancel();
        Navigator.of(context).pushReplacementNamed(
          LiveRideTrackingScreen.routeName,
          arguments: fresh,
        );
        return;
      }
      if (fresh.status == 'cancelled') {
        _pollTimer?.cancel();
        _snack('The ride was cancelled.');
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      setState(() => _ride = fresh);
    } on ApiException {
      // Ignore transient polling failures; retried on the next tick.
    }
  }

  Future<void> _cancelRide() async {
    final ride = _ride;
    if (ride == null) return;
    final navigator = Navigator.of(context);
    setState(() => _cancelling = true);
    _pollTimer?.cancel();
    try {
      await RidesApi.cancel(ride.id, reason: 'Cancelled by customer');
      if (!mounted) return;
      _snack('Ride cancelled.');
      navigator.popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
      _snack(e.message);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
    final driver = ride?.driver;
    final textTheme = Theme.of(context).textTheme;

    if (ride == null || driver == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Driver')),
        body: Center(
          child: Text('Ride not found.', style: textTheme.bodyLarge),
        ),
      );
    }

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
                          'On the way • ${driver.name} • '
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.accentBlueSoft,
                        child: Icon(Icons.person, color: AppColors.primaryNavy, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: driver.rating, size: 14),
                                const SizedBox(width: 6),
                                Text(driver.rating.toStringAsFixed(1), style: textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${driver.vehicleModel} • ${driver.plateNumber}',
                              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      _CircleAction(
                        icon: Icons.call,
                        color: AppColors.brandLime,
                        onTap: () => _snack(
                          driver.phone.isEmpty ? 'Driver phone unavailable' : 'Call ${driver.phone}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelling ? null : _cancelRide,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_cancelling ? 'Cancelling…' : 'Cancel ride'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Track Ride',
                          backgroundColor: AppColors.primaryNavy,
                          borderRadius: 14,
                          onPressed: () {
                            _pollTimer?.cancel();
                            Navigator.of(context).pushReplacementNamed(
                              LiveRideTrackingScreen.routeName,
                              arguments: ride,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Fare ৳${ride.fare.toStringAsFixed(0)} • ${statusLabel(ride.paymentMethod)}',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
