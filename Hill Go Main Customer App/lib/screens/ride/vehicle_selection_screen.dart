import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/route_result.dart';
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

  /// Multipliers applied to the base OSRM fare for each vehicle type.
  static const _multipliers = [0.7, 1.0, 1.5]; // Bike, Car, XL

  void _continue(RideLocationArgs? rideArgs, List<VehicleOption> options) {
    Navigator.of(context).pushNamed(
      FareEstimateScreen.routeName,
      arguments: {
        'vehicle': options[_selectedIndex],
        if (rideArgs != null) 'ride': rideArgs,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final rideArgs = rawArgs is RideLocationArgs ? rawArgs : null;

    // Build vehicle list; if we have a real fare, scale prices from it.
    final options = List<VehicleOption>.generate(dummyVehicleOptions.length, (i) {
      final base = dummyVehicleOptions[i];
      if (rideArgs == null) return base;
      final priced = (rideArgs.fareTaka * _multipliers[i]).roundToDouble();
      final etaMin = rideArgs.durationMin.round();
      return VehicleOption(
        name: base.name,
        icon: base.icon,
        eta: '~$etaMin min trip',
        price: priced < 50 ? 50 : priced,
        description: base.description,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Choose a ride'),
      body: Column(
        children: [
          const MapPlaceholder(height: 200, showRoute: true),
          if (rideArgs != null)
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = options[index];
                final selected = index == _selectedIndex;
                return _VehicleTile(
                  vehicle: vehicle,
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
              label: 'Continue',
              backgroundColor: AppColors.primaryNavy,
              borderRadius: 14,
              onPressed: () => _continue(rideArgs, options),
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
    required this.selected,
    required this.onTap,
  });

  final VehicleOption vehicle;
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
                    '${vehicle.eta} • ${vehicle.description}',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${vehicle.price.toStringAsFixed(0)}',
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
