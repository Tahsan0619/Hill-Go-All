import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../../providers/driver_provider.dart';
import '../../services/fare_config.dart';
import '../../services/routing_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/hillgo_map.dart';

class TripNavigationScreen extends StatefulWidget {
  const TripNavigationScreen({super.key});

  @override
  State<TripNavigationScreen> createState() => _TripNavigationScreenState();
}

class _TripNavigationScreenState extends State<TripNavigationScreen>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  final _routing = RoutingService();
  final _distance = const Distance();

  StreamSubscription<Position>? _gpsSub;
  Ticker? _simTicker;
  Timer? _cancelPoll;
  Duration _simElapsed = Duration.zero;
  bool _handlingRemoteCancel = false;

  NavRoute? _route;
  LatLng? _driverPos;
  double _heading = 0;
  bool _loadingRoute = true;
  bool _followCamera = true;
  bool _usingLiveGps = false;
  bool _routeRefreshPending = false;
  String? _routeError;
  LatLng? _lastDestination;
  TripStatus? _lastStatus;

  /// City driving speed used when GPS is unavailable (~32 km/h).
  static const _simSpeedMps = 9.0;

  List<double> _cumMeters = const [];
  double _routeLengthM = 0;
  double _traveledM = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _cancelPoll?.cancel();
    _gpsSub?.cancel();
    _stopSimulation();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _startCancelWatch();
    await _ensureRoute();
    await _startLocationTracking();
  }

  /// Detect customer cancel after accept while the rider is on navigation.
  void _startCancelWatch() {
    _cancelPoll?.cancel();
    _cancelPoll = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _handlingRemoteCancel) return;
      final driver = context.read<DriverProvider>();
      if (driver.activeTrip == null) return;
      final cancelled = await driver.syncActiveTripCancel();
      if (!mounted || !cancelled || _handlingRemoteCancel) return;
      await _onRemoteCancel();
    });
  }

  Future<void> _onRemoteCancel() async {
    if (_handlingRemoteCancel || !mounted) return;
    _handlingRemoteCancel = true;
    _cancelPoll?.cancel();
    _gpsSub?.cancel();
    _stopSimulation();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Ride cancelled'),
        content: const Text(
          'The customer cancelled this ride. You are free to take new offers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await context.read<DriverProvider>().clearActiveTrip();
    if (!mounted) return;
    context.go('/home');
  }

  LatLng _destinationFor(Trip trip) {
    return trip.isGoingToPickup
        ? LatLng(trip.pickupLat, trip.pickupLng)
        : LatLng(trip.dropoffLat, trip.dropoffLng);
  }

  void _buildCumulative(List<LatLng> points) {
    _cumMeters = List<double>.filled(points.length, 0);
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _distance.as(LengthUnit.Meter, points[i - 1], points[i]);
      _cumMeters[i] = total;
    }
    _routeLengthM = total;
  }

  LatLng _pointAtDistance(double meters) {
    final points = _route?.points;
    if (points == null || points.length < 2) {
      return _driverPos ?? const LatLng(DhakaMap.lat, DhakaMap.lng);
    }
    final target = meters.clamp(0, _routeLengthM);
    if (target <= 0) return points.first;
    if (target >= _routeLengthM) return points.last;

    var i = 1;
    while (i < _cumMeters.length && _cumMeters[i] < target) {
      i++;
    }
    final prev = points[i - 1];
    final next = points[i];
    final segStart = _cumMeters[i - 1];
    final segEnd = _cumMeters[i];
    final segLen = (segEnd - segStart).clamp(0.0001, double.infinity);
    final t = ((target - segStart) / segLen).clamp(0.0, 1.0);
    return LatLng(
      prev.latitude + (next.latitude - prev.latitude) * t,
      prev.longitude + (next.longitude - prev.longitude) * t,
    );
  }

  double _bearingAt(double meters) {
    final a = _pointAtDistance(meters);
    final b = _pointAtDistance(meters + 8);
    return _distance.bearing(a, b);
  }

  Future<void> _ensureRoute() async {
    final trip = context.read<DriverProvider>().activeTrip;
    if (trip == null) return;

    final dest = _destinationFor(trip);
    if (_route != null &&
        _lastDestination != null &&
        _lastStatus == trip.status &&
        _distance.as(LengthUnit.Meter, _lastDestination!, dest) < 5) {
      return;
    }

    _stopSimulation();
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    final start = (!_usingLiveGps || _driverPos == null)
        ? LatLng(
            trip.pickupLat + (trip.isGoingToDrop ? 0.0015 : -0.0035),
            trip.pickupLng + (trip.isGoingToDrop ? 0.0015 : -0.0025),
          )
        : _driverPos!;

    final route = await _routing.getDrivingRoute(
      _usingLiveGps && _driverPos != null ? _driverPos! : start,
      dest,
    );

    if (!mounted) return;

    if (route == null || route.points.length < 2) {
      final fallback = NavRoute(
        points: [start, dest],
        steps: const [],
        distanceMeters: _distance.as(LengthUnit.Meter, start, dest),
        durationSeconds: 600,
      );
      _buildCumulative(fallback.points);
      setState(() {
        _loadingRoute = false;
        _routeError = 'Could not load live route';
        _route = fallback;
        _driverPos = start;
        _traveledM = 0;
        _lastDestination = dest;
        _lastStatus = trip.status;
      });
      if (!_usingLiveGps) _startSimulation();
      return;
    }

    _buildCumulative(route.points);
    setState(() {
      _route = route;
      _loadingRoute = false;
      _lastDestination = dest;
      _lastStatus = trip.status;
      _driverPos = route.points.first;
      _traveledM = 0;
      _heading = _bearingAt(0);
    });

    _moveCamera(_driverPos!);
    if (!_usingLiveGps) _startSimulation();
  }

  Future<void> _startLocationTracking() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _startSimulation();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _startSimulation();
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final live = LatLng(current.latitude, current.longitude);

      if (!mounted) return;
      final trip = context.read<DriverProvider>().activeTrip;
      if (trip != null) {
        final toJob = _distance.as(
          LengthUnit.Meter,
          live,
          LatLng(trip.pickupLat, trip.pickupLng),
        );
        // Far from the job coords → fall back to smooth route playback.
        if (toJob > 80000) {
          _startSimulation();
          return;
        }
      }

      _stopSimulation();
      setState(() {
        _usingLiveGps = true;
        _driverPos = live;
        _heading = current.heading.isNaN ? _heading : current.heading;
      });
      await _ensureRoute();

      await _gpsSub?.cancel();
      _gpsSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).listen((pos) {
        if (!mounted) return;
        final next = LatLng(pos.latitude, pos.longitude);
        final prev = _driverPos;
        setState(() {
          _driverPos = next;
          if (!pos.heading.isNaN && pos.heading >= 0) {
            _heading = pos.heading;
          } else if (prev != null) {
            _heading = _distance.bearing(prev, next);
          }
        });
        if (_followCamera) _moveCamera(next);
        // Report live position to dispatch (throttled inside the provider).
        context.read<DriverProvider>().reportLocation(next.latitude, next.longitude);
      });
    } catch (_) {
      _startSimulation();
    }
  }

  void _stopSimulation() {
    _simTicker?.dispose();
    _simTicker = null;
    _simElapsed = Duration.zero;
  }

  void _startSimulation() {
    if (_usingLiveGps) return;
    if (_simTicker != null) return;
    final points = _route?.points;
    if (points == null || points.length < 2 || _routeLengthM <= 0) return;

    _simElapsed = Duration.zero;
    _simTicker = createTicker((elapsed) {
      if (!mounted || _route == null) return;
      final dt = (elapsed - _simElapsed).inMicroseconds / 1e6;
      _simElapsed = elapsed;
      if (dt <= 0 || dt > 0.25) return;

      _traveledM = (_traveledM + _simSpeedMps * dt).clamp(0, _routeLengthM);
      final pos = _pointAtDistance(_traveledM);
      final heading = _bearingAt(_traveledM);

      setState(() {
        _driverPos = pos;
        _heading = heading;
      });
      if (_followCamera) _moveCamera(pos);

      if (_traveledM >= _routeLengthM) {
        _stopSimulation();
      }
    });
    _simTicker!.start();
  }

  void _moveCamera(LatLng point) {
    try {
      _mapController.moveAndRotate(
        point,
        math.max(_mapController.camera.zoom, 16.2),
        -_heading,
      );
    } catch (_) {
      try {
        _mapController.move(point, math.max(_mapController.camera.zoom, 16.2));
      } catch (_) {}
    }
  }

  Future<void> _openExternalNav(LatLng dest) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${dest.latitude},${dest.longitude}'
      '&travelmode=driving&dir_action=navigate',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _maneuverIcon(IconHint? hint) {
    return switch (hint) {
      IconHint.turnLeft => Icons.turn_left,
      IconHint.turnRight => Icons.turn_right,
      IconHint.uTurn => Icons.u_turn_right,
      IconHint.arrive => Icons.flag,
      IconHint.depart => Icons.navigation,
      IconHint.straight || null => Icons.straight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final trip = driver.activeTrip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const EmptyView(
          title: 'No active trip',
          subtitle: 'Accept an offer to start navigation.',
        ),
      );
    }

    // Refresh route when trip phase changes (pickup → dropoff).
    // Latch immediately so rebuilds don't queue duplicate route fetches / tickers.
    if (_lastStatus != null &&
        _lastStatus != trip.status &&
        !_routeRefreshPending) {
      _routeRefreshPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _routeRefreshPending = false;
        if (!mounted) return;
        _stopSimulation();
        await _ensureRoute();
      });
    }

    final pickup = LatLng(trip.pickupLat, trip.pickupLng);
    final dropoff = LatLng(trip.dropoffLat, trip.dropoffLng);
    final dest = _destinationFor(trip);
    final driverPos = _driverPos ?? pickup;
    final goingToDrop = trip.isGoingToDrop;

    final progress = _route == null
        ? null
        : RoutingService.progressAlong(_route!, driverPos);
    final nextStep = progress?.nextStep;
    final remainMeters = progress?.meters ?? _route?.distanceMeters ?? 0;
    final remainSeconds = progress?.seconds ?? _route?.durationSeconds ?? 0;
    final etaMin = math.max(1, (remainSeconds / 60).round());

    return Scaffold(
      body: Stack(
        children: [
          HillGoMap(
            mapController: _mapController,
            center: driverPos,
            zoom: 15.5,
            markers: [
              HillGoMap.driverMarker(driverPos, heading: _heading),
              HillGoMap.destinationMarker(dest, isDropoff: goingToDrop),
              if (!goingToDrop)
                Marker(
                  point: dropoff,
                  width: 28,
                  height: 28,
                  child: const Icon(Icons.circle, size: 12, color: AppColors.orange),
                ),
            ],
            polylines: [
              if (_route != null)
                Polyline(
                  points: _route!.points,
                  color: AppColors.mapBlue,
                  strokeWidth: 6,
                  borderStrokeWidth: 2,
                  borderColor: Colors.white,
                ),
            ],
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture && _followCamera) {
                setState(() => _followCamera = false);
              }
            },
          ),
          if (_loadingRoute)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.accent,
                backgroundColor: Colors.transparent,
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDeep,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _maneuverIcon(nextStep?.iconHint),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    RoutingService.formatDistance(remainMeters),
                                    style: AppTextStyles.title.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    nextStep?.instruction ??
                                        (_routeError ??
                                            (goingToDrop
                                                ? 'Continue to ${trip.dropoffName}'
                                                : 'Navigate to ${trip.pickupName}')),
                                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoundNavButton(
                      icon: Icons.map_outlined,
                      tooltip: 'Open Google Maps',
                      onTap: () => _openExternalNav(dest),
                    ),
                    const SizedBox(width: 8),
                    _RoundNavButton(
                      icon: Icons.emergency,
                      bordered: true,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Safety tools', style: AppTextStyles.title),
                                const SizedBox(height: 12),
                                ListTile(
                                  leading: const Icon(Icons.sos, color: AppColors.tips),
                                  title: const Text('Emergency assist'),
                                  subtitle: const Text('Call 999 (national emergency)'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final uri = Uri.parse('tel:999');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.support_agent),
                                  title: const Text('Contact HillGo support'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final uri = Uri.parse('mailto:support@hillgo.com');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 210,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() => _followCamera = true);
                    _moveCamera(driverPos);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: _followCamera ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 6),
                    ],
                  ),
                  child: Text(
                    _usingLiveGps ? 'LIVE GPS' : 'LIVE TRACKING',
                    style: AppTextStyles.labelCaps.copyWith(
                      fontSize: 9,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.cardBlueTint,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      trip.customerName,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              Text(
                                '${trip.jobType.label} • ${trip.customerRating}★ • ${formatTaka(trip.earning)}',
                                style: AppTextStyles.caption,
                              ),
                              if (trip.isCod)
                                Text(
                                  trip.note ?? 'COD — collect cash',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.orangeDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _ActionIcon(
                          icon: Icons.phone,
                          onTap: () async {
                            if (trip.customerPhone.isEmpty) return;
                            final uri = Uri.parse('tel:${trip.customerPhone}');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _ActionIcon(
                          icon: Icons.sms_outlined,
                          onTap: () async {
                            if (trip.customerPhone.isEmpty) return;
                            final uri = Uri.parse('sms:${trip.customerPhone}');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AccentButton(
                            label: trip.nextActionLabel,
                            loading: driver.isLoading,
                            onPressed: () async {
                              final wasComplete = trip.nextStatus == TripStatus.completed;
                              final completed = driver.activeTrip;
                              final ok = await driver.advanceJob();
                              if (!context.mounted) return;
                              if (!ok) {
                                if (driver.error?.contains('cancelled') ?? false) {
                                  await _onRemoteCancel();
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(driver.error ?? 'Could not update status')),
                                );
                                return;
                              }
                              if (wasComplete) {
                                context.go('/trip/completed', extra: completed);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trip.isGoingToDrop ? 'TO DROP' : 'TO PICKUP',
                              style: AppTextStyles.labelCaps.copyWith(fontSize: 10),
                            ),
                            Text(
                              'ETA $etaMin MIN',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundNavButton extends StatelessWidget {
  const _RoundNavButton({
    required this.icon,
    required this.onTap,
    this.bordered = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool bordered;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: AppColors.primaryDeep,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: bordered ? Border.all(color: AppColors.tips, width: 1.5) : null,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 42, height: 42, child: Icon(icon, color: AppColors.primary)),
      ),
    );
  }
}
