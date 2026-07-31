import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../models/route_result.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/map_placeholder.dart';
import '../../widgets/primary_button.dart';
import 'fare_estimate_screen.dart';

class VehicleSelectionScreen extends StatefulWidget {
  const VehicleSelectionScreen({super.key});

  static const String routeName = '/ride/vehicle';

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  int _selectedIndex = 0;
  RideLocationArgs? _rideArgs;
  bool _quotesRequested = false;

  /// Server quotes per vehicle type (bike/car/xl); null while loading.
  final Map<String, RideQuote> _quotes = {};
  String? _quoteError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    _rideArgs = rawArgs is RideLocationArgs ? rawArgs : null;
    if (!_quotesRequested && _rideArgs != null) {
      _quotesRequested = true;
      _loadQuotes();
    }
  }

  Future<void> _loadQuotes() async {
    final ride = _rideArgs;
    if (ride == null) return;
    setState(() => _quoteError = null);
    try {
      final results = await Future.wait([
        for (final option in kVehicleOptions)
          RidesApi.quote(
            vehicleType: option.type,
            distanceKm: ride.distanceKm,
            durationMin: ride.durationMin,
          ),
      ]);
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < kVehicleOptions.length; i++) {
          _quotes[kVehicleOptions[i].type] = results[i];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _quoteError = e.toString());
    }
  }

  void _continue() {
    final option = kVehicleOptions[_selectedIndex];
    final quote = _quotes[option.type];
    if (quote == null) return;
    Navigator.of(context).pushNamed(
      FareEstimateScreen.routeName,
      arguments: {
        'vehicle': option,
        'quote': quote,
        'ride': _rideArgs,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideArgs = _rideArgs;

    if (rideArgs == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const HillgoAppBar(title: 'Choose a ride'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Select a pickup and drop-off location first.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final selectedQuote = _quotes[kVehicleOptions[_selectedIndex].type];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Choose a ride'),
      body: Column(
        children: [
          const MapPlaceholder(height: 200, showRoute: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              '${rideArgs.distanceKm.toStringAsFixed(1)} km · '
              '${rideArgs.durationMin.round()} min · '
              '${rideArgs.pickup.displayName.split(',').first} → '
              '${rideArgs.destination.displayName.split(',').first}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          if (_quoteError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Could not load fares. Check your connection.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.redAccent),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadQuotes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              itemCount: kVehicleOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = kVehicleOptions[index];
                final selected = index == _selectedIndex;
                return _VehicleTile(
                  vehicle: vehicle,
                  quote: _quotes[vehicle.type],
                  etaLabel: '~${rideArgs.durationMin.round()} min trip',
                  selected: selected,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
              ],
            ),
            child: PrimaryButton(
              label: selectedQuote == null ? 'Fetching fare…' : 'Continue',
              backgroundColor: AppColors.primaryNavy,
              borderRadius: 14,
              onPressed: selectedQuote == null ? null : _continue,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.quote,
    required this.etaLabel,
    required this.selected,
    required this.onTap,
  });

  final VehicleOption vehicle;
  final RideQuote? quote;
  final String etaLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryNavy : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                vehicle.icon,
                color: selected ? AppColors.white : AppColors.primaryNavy,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$etaLabel • ${vehicle.description}',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                quote == null
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryNavy,
                        ),
                      )
                    : Text(
                        '৳${quote!.fare.toStringAsFixed(0)}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                if (selected) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.check_circle, color: AppColors.accentOrange, size: 18),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
