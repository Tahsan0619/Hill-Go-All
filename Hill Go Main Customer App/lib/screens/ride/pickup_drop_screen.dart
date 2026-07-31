import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../config/fare_config.dart';
import '../../models/place_result.dart';
import '../../models/route_result.dart';
import '../../services/fare_service.dart';
import '../../services/nominatim_service.dart';
import '../../services/osrm_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import 'vehicle_selection_screen.dart';

/// Ride booking: map (OSM) + Nominatim search + OSRM route + fare estimate.
///
/// API flow
/// --------
/// 1. On open → Geolocator (device GPS) → Nominatim reverse → pickup marker
/// 2. Typing in a field → Nominatim search (debounced) → autocomplete list
/// 3. Destination selected → show pickup + destination markers
/// 4. Confirm Location → OSRM route → polyline + km/min → FareService → UI
class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({super.key});

  static const String routeName = '/ride/pickup';

  @override
  State<PickupDropScreen> createState() => _PickupDropScreenState();
}

class _PickupDropScreenState extends State<PickupDropScreen> {
  // --- Services ---
  final _nominatim = NominatimService();
  final _osrm = OsrmService();
  final _mapController = MapController();

  // --- Text fields ---
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropFocus = FocusNode();

  // --- Location / route state ---
  PlaceResult? _pickup;
  PlaceResult? _destination;
  List<LatLng> _routePoints = [];
  double? _distanceKm;
  double? _durationMin;
  double? _fareTaka;

  // --- Autocomplete ---
  Timer? _searchDebounce;
  List<PlaceResult> _suggestions = [];
  bool _searchingPickup = true; // which field is being typed
  bool _showSuggestions = false;

  // --- UI flags ---
  bool _locating = true;
  bool _confirming = false;
  String? _error;

  /// Dhaka fallback if GPS is unavailable.
  static const _fallbackCenter = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pickupController.dispose();
    _dropController.dispose();
    _pickupFocus.dispose();
    _dropFocus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // STEP 1 — Detect GPS + reverse-geocode pickup (Nominatim)
  // ---------------------------------------------------------------------------
  Future<void> _detectCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _useFallbackPickup('Location services are off — using Dhaka center.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _useFallbackPickup('Location permission denied — using Dhaka center.');
        return;
      }

      // Device GPS (no HTTP — local sensor API)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // API: Nominatim reverse geocode
      // GET nominatim.openstreetmap.org/reverse?lat=...&lon=...
      final place = await _nominatim.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _pickup = place;
        _pickupController.text = _shortName(place.displayName);
        _locating = false;
      });
      _mapController.move(place.latLng, 15);
    } catch (e) {
      await _useFallbackPickup('Could not get location: $e');
    }
  }

  Future<void> _useFallbackPickup(String message) async {
    final fallback = PlaceResult(
      displayName: 'Dhaka, Bangladesh',
      latitude: _fallbackCenter.latitude,
      longitude: _fallbackCenter.longitude,
    );
    if (!mounted) return;
    setState(() {
      _pickup = fallback;
      _pickupController.text = fallback.displayName;
      _locating = false;
      _error = message;
    });
    _mapController.move(_fallbackCenter, 13);
  }

  // ---------------------------------------------------------------------------
  // STEP 2 — Nominatim autocomplete (debounced while typing)
  // ---------------------------------------------------------------------------
  void _onQueryChanged(String query, {required bool isPickup}) {
    _searchDebounce?.cancel();
    _searchingPickup = isPickup;
    _clearRouteSummary(); // new typing invalidates previous confirm result

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Debounce ~450ms to respect Nominatim's ~1 req/sec guideline
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        // API: Nominatim search
        // GET nominatim.openstreetmap.org/search?q=...&format=json
        final results = await _nominatim.searchPlaces(query);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
          _error = 'Address search failed: $e';
        });
      }
    });
  }

  void _selectSuggestion(PlaceResult place) {
    setState(() {
      if (_searchingPickup) {
        _pickup = place;
        _pickupController.text = _shortName(place.displayName);
        _pickupFocus.unfocus();
      } else {
        _destination = place;
        _dropController.text = _shortName(place.displayName);
        _dropFocus.unfocus();
      }
      _suggestions = [];
      _showSuggestions = false;
      _error = null;
    });
    _fitMapToMarkers();
  }

  // ---------------------------------------------------------------------------
  // STEP 3+4 — Confirm → OSRM route → fare → show on screen
  // ---------------------------------------------------------------------------
  Future<void> _confirmLocation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showSuggestions = false;
      _error = null;
    });

    if (_pickup == null) {
      setState(() => _error = 'Set a pickup location first.');
      return;
    }
    if (_destination == null) {
      setState(() => _error = 'Select a destination from the suggestions.');
      return;
    }

    setState(() => _confirming = true);

    try {
      // API: OSRM driving route
      // GET router.project-osrm.org/route/v1/driving/{lon1},{lat1};{lon2},{lat2}
      final route = await _osrm.getRoute(
        pickupLat: _pickup!.latitude,
        pickupLon: _pickup!.longitude,
        destLat: _destination!.latitude,
        destLon: _destination!.longitude,
      );

      // Local math only — no API
      final fare = FareService.calculate(
        distanceKm: route.distanceKm,
        durationMin: route.durationMin,
      );

      if (!mounted) return;
      setState(() {
        _routePoints = route.points;
        _distanceKm = route.distanceKm;
        _durationMin = route.durationMin;
        _fareTaka = fare;
        _confirming = false;
      });
      _fitMapToMarkers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _confirming = false;
        _error = 'Could not calculate route: $e';
      });
    }
  }

  void _continueToVehicles() {
    if (_pickup == null ||
        _destination == null ||
        _distanceKm == null ||
        _durationMin == null ||
        _fareTaka == null) {
      return;
    }

    Navigator.of(context).pushNamed(
      VehicleSelectionScreen.routeName,
      arguments: RideLocationArgs(
        pickup: _pickup!,
        destination: _destination!,
        distanceKm: _distanceKm!,
        durationMin: _durationMin!,
        fareTaka: _fareTaka!,
        routePoints: _routePoints,
      ),
    );
  }

  void _clearRouteSummary() {
    if (_distanceKm == null && _routePoints.isEmpty) return;
    setState(() {
      _routePoints = [];
      _distanceKm = null;
      _durationMin = null;
      _fareTaka = null;
    });
  }

  void _fitMapToMarkers() {
    final points = <LatLng>[
      if (_pickup != null) _pickup!.latLng,
      if (_destination != null) _destination!.latLng,
      ..._routePoints,
    ];
    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  /// Shorten long Nominatim display names for the text field.
  String _shortName(String full) {
    final parts = full.split(',');
    if (parts.length <= 3) return full;
    return parts.take(3).join(',').trim();
  }

  bool get _hasFareSummary =>
      _distanceKm != null && _durationMin != null && _fareTaka != null;

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Set your route'),
      body: Column(
        children: [
          Expanded(child: _buildMap()),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _fallbackCenter,
            initialZoom: 13,
          ),
          children: [
            // Free OSM raster tiles (no API key)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.hillgo',
              maxZoom: 19,
            ),
            // OSRM road polyline
            if (_routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.primaryNavy,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        if (_locating)
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Chip(
                avatar: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                label: Text('Finding your location…'),
                backgroundColor: AppColors.white,
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'recenter_pickup',
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryNavy,
            onPressed: _detectCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_pickup != null) {
      markers.add(
        Marker(
          point: _pickup!.latLng,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.radio_button_checked,
            color: AppColors.primaryNavy,
            size: 32,
          ),
        ),
      );
    }

    if (_destination != null) {
      markers.add(
        Marker(
          point: _destination!.latLng,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.location_on,
            color: AppColors.accentOrange,
            size: 40,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you headed?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 18),
          _LocationField(
            controller: _pickupController,
            focusNode: _pickupFocus,
            hint: 'Enter pickup location',
            icon: Icons.radio_button_checked,
            iconColor: AppColors.primaryNavy,
            onChanged: (q) => _onQueryChanged(q, isPickup: true),
            onFocus: () => setState(() => _searchingPickup = true),
          ),
          const _ConnectorLine(),
          _LocationField(
            controller: _dropController,
            focusNode: _dropFocus,
            hint: 'Where to?',
            icon: Icons.location_on,
            iconColor: AppColors.accentOrange,
            onChanged: (q) => _onQueryChanged(q, isPickup: false),
            onFocus: () => setState(() => _searchingPickup = false),
          ),
          if (_showSuggestions) ...[
            const SizedBox(height: 8),
            _SuggestionList(
              suggestions: _suggestions,
              onSelect: _selectSuggestion,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
            ),
          ],
          if (_hasFareSummary) ...[
            const SizedBox(height: 16),
            _FareSummaryCard(
              distanceKm: _distanceKm!,
              durationMin: _durationMin!,
              fareTaka: _fareTaka!,
            ),
          ],
          const SizedBox(height: 24),
          if (_confirming)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_hasFareSummary)
            PrimaryButton(
              label: 'Continue',
              backgroundColor: AppColors.accentOrange,
              borderRadius: 14,
              onPressed: _continueToVehicles,
            )
          else
            PrimaryButton(
              label: 'Confirm Location',
              backgroundColor: AppColors.primaryNavy,
              borderRadius: 14,
              onPressed: _confirmLocation,
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Small UI pieces (kept in this file so the screen stays self-contained)
// =============================================================================

class _FareSummaryCard extends StatelessWidget {
  const _FareSummaryCard({
    required this.distanceKm,
    required this.durationMin,
    required this.fareTaka,
  });

  final double distanceKm;
  final double durationMin;
  final double fareTaka;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip estimate',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryNavy,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${distanceKm.toStringAsFixed(1)} km',
                  style: textStyle,
                ),
              ),
              Expanded(
                child: Text(
                  '${durationMin.round()} min',
                  style: textStyle,
                ),
              ),
              Text(
                '৳${fareTaka.toStringAsFixed(0)}',
                style: textStyle?.copyWith(
                  color: AppColors.accentOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fare = ৳${FareConfig.baseFare.toStringAsFixed(0)} + '
            '(${distanceKm.toStringAsFixed(1)}×৳${FareConfig.ratePerKm.toStringAsFixed(0)}) + '
            '(${durationMin.round()}×৳${FareConfig.ratePerMin.toStringAsFixed(0)})'
            ' · min ৳${FareConfig.minimumFare.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.suggestions,
    required this.onSelect,
  });

  final List<PlaceResult> suggestions;
  final ValueChanged<PlaceResult> onSelect;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.inputBorder),
          itemBuilder: (context, index) {
            final place = suggestions[index];
            return ListTile(
              dense: true,
              leading: const Icon(Icons.place_outlined, size: 20),
              title: Text(
                place.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              onTap: () => onSelect(place),
            );
          },
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
    required this.onFocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) onFocus();
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              width: 1.5,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.inputBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
