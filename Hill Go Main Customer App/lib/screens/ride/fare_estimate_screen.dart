import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../models/route_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import 'driver_searching_screen.dart';

class FareEstimateScreen extends StatefulWidget {
  const FareEstimateScreen({super.key});

  static const String routeName = '/ride/fare';

  @override
  State<FareEstimateScreen> createState() => _FareEstimateScreenState();
}

class _FareEstimateScreenState extends State<FareEstimateScreen> {
  String _paymentMethod = 'cash';

  static const _paymentOptions = [
    ('cash', 'Cash', Icons.payments_outlined),
    ('wallet', 'Wallet', Icons.account_balance_wallet_outlined),
    ('card', 'Card', Icons.credit_card),
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    VehicleOption? vehicle;
    RideQuote? quote;
    RideLocationArgs? ride;

    if (args is Map) {
      if (args['vehicle'] is VehicleOption) {
        vehicle = args['vehicle'] as VehicleOption;
      }
      if (args['quote'] is RideQuote) {
        quote = args['quote'] as RideQuote;
      }
      if (args['ride'] is RideLocationArgs) {
        ride = args['ride'] as RideLocationArgs;
      }
    }

    if (vehicle == null || quote == null || ride == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const HillgoAppBar(title: 'Fare estimate'),
        body: Center(
          child: Text(
            'Ride details not found.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final pickupLabel = ride.pickup.displayName;
    final dropLabel = ride.destination.displayName;
    final distanceKm = ride.distanceKm;
    final durationMin = ride.durationMin;
    final distanceCharge = distanceKm * quote.perKm;
    final timeCharge = durationMin * quote.perMin;

    final rideArgs = ride;
    final quoteArgs = quote;
    final vehicleArgs = vehicle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Fare estimate'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.primaryNavy,
                    label: pickupLabel,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 9),
                    child: SizedBox(
                      height: 24,
                      child: VerticalDivider(color: AppColors.inputBorder, thickness: 1.5),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.location_on,
                    iconColor: AppColors.accentOrange,
                    label: dropLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(vehicle.icon, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${vehicle.name} • ${distanceKm.toStringAsFixed(1)} km • ${durationMin.round()} min',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Fare breakdown', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  FareRow(label: 'Base fare', value: '৳${quote.base.toStringAsFixed(0)}'),
                  FareRow(
                    label: 'Distance (${distanceKm.toStringAsFixed(1)} km)',
                    value: '৳${distanceCharge.toStringAsFixed(0)}',
                  ),
                  FareRow(
                    label: 'Time (${durationMin.round()} min)',
                    value: '৳${timeCharge.toStringAsFixed(0)}',
                  ),
                  if (quote.multiplier != 1)
                    FareRow(
                      label: '${vehicleArgs.name} rate',
                      value: '×${quote.multiplier.toStringAsFixed(2)}',
                    ),
                  const Divider(color: AppColors.inputBorder, height: 24),
                  FareRow(label: 'Total', value: '৳${quote.fare.toStringAsFixed(0)}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Pay with', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (value, label, icon) in _paymentOptions) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _paymentMethod = value),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _paymentMethod == value
                                ? AppColors.primaryNavy
                                : AppColors.cardBorder,
                            width: _paymentMethod == value ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(icon,
                                color: _paymentMethod == value
                                    ? AppColors.primaryNavy
                                    : AppColors.textSecondary),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _paymentMethod == value
                                    ? AppColors.primaryNavy
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (value != _paymentOptions.last.$1) const SizedBox(width: 10),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
          ],
        ),
        child: PrimaryButton(
          label: 'Book Ride',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: () => Navigator.of(context).pushNamed(
            DriverSearchingScreen.routeName,
            arguments: {
              'ride': rideArgs,
              'vehicle': vehicleArgs,
              'quote': quoteArgs,
              'payment_method': _paymentMethod,
            },
          ),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
