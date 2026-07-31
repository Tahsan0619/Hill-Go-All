import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../models/route_result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';
import 'driver_assigned_screen.dart';

class DriverSearchingScreen extends StatefulWidget {
  const DriverSearchingScreen({super.key});

  static const String routeName = '/ride/searching';

  @override
  State<DriverSearchingScreen> createState() => _DriverSearchingScreenState();
}

class _DriverSearchingScreenState extends State<DriverSearchingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _pollTimer;
  Timer? _timeoutTimer;

  RideEntry? _ride;
  String? _error;
  bool _timedOut = false;
  bool _cancelling = false;
  bool _createStarted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_createStarted) return;
    _createStarted = true;
    _createRide();
  }

  Future<void> _createRide() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) {
      setState(() => _error = 'Ride details not found.');
      return;
    }
    final ride = args['ride'] as RideLocationArgs?;
    final vehicle = args['vehicle'] as VehicleOption?;
    final paymentMethod = (args['payment_method'] as String?) ?? 'cash';
    if (ride == null || vehicle == null) {
      setState(() => _error = 'Ride details not found.');
      return;
    }

    try {
      final created = await RidesApi.create(
        vehicleType: vehicle.type,
        pickup: ride.pickup.displayName,
        drop: ride.destination.displayName,
        pickupLat: ride.pickup.latitude,
        pickupLng: ride.pickup.longitude,
        dropLat: ride.destination.latitude,
        dropLng: ride.destination.longitude,
        distanceKm: ride.distanceKm,
        durationMin: ride.durationMin,
        paymentMethod: paymentMethod,
      );
      if (!mounted) return;
      setState(() => _ride = created);
      _startPolling();
      _timeoutTimer = Timer(const Duration(seconds: 90), () {
        if (mounted) setState(() => _timedOut = true);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
    // Immediate first check so assignment feels real-time.
    unawaited(_poll());
  }

  Future<void> _poll() async {
    final ride = _ride;
    if (ride == null || _cancelling) return;
    try {
      final fresh = await RidesApi.show(ride.id);
      if (!mounted) return;
      if (fresh.status == 'cancelled') {
        _pollTimer?.cancel();
        setState(() => _error = 'The ride was cancelled.');
        return;
      }
      if (fresh.driver != null && fresh.status != 'searching') {
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        Navigator.of(context).pushReplacementNamed(
          DriverAssignedScreen.routeName,
          arguments: fresh,
        );
        return;
      }
      setState(() => _ride = fresh);
    } on ApiException {
      // Transient polling errors are ignored; the next tick retries.
    }
  }

  Future<void> _cancel() async {
    final ride = _ride;
    final navigator = Navigator.of(context);
    if (ride == null) {
      navigator.maybePop();
      return;
    }
    setState(() => _cancelling = true);
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    try {
      await RidesApi.cancel(ride.id, reason: 'Cancelled while searching');
    } on ApiException {
      // Even if cancel fails (e.g. already assigned), leave the screen.
    }
    if (mounted) navigator.maybePop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const MapPlaceholder(),
          Container(color: AppColors.primaryNavy.withValues(alpha: 0.08)),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                if (_error != null) ...[
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.redAccent.withValues(alpha: 0.8)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(fontSize: 17),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            _PulseRing(progress: _pulseController.value),
                            _PulseRing(progress: (_pulseController.value + 0.5) % 1),
                            child!,
                          ],
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryNavy,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_taxi, color: AppColors.white, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _ride == null
                        ? 'Booking your ride...'
                        : _timedOut
                            ? 'Still looking for a driver…'
                            : 'Looking for nearby drivers...',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _timedOut
                          ? 'This is taking longer than usual. You can keep waiting or cancel the ride.'
                          : _ride == null
                              ? 'Sending your request to the network'
                              : 'Ride ${_ride!.code} · This usually takes less than a minute',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: OutlinedButton(
                    onPressed: _cancelling
                        ? null
                        : _error != null
                            ? () => Navigator.of(context).maybePop()
                            : _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.inputBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      _cancelling
                          ? 'Cancelling…'
                          : _error != null
                              ? 'Go back'
                              : 'Cancel',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = 72 + progress * 68;
    return Opacity(
      opacity: (1 - progress).clamp(0.0, 1.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentOrange, width: 2),
        ),
      ),
    );
  }
}
