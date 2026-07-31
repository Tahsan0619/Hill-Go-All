import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/parcels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';
import 'parcel_summary_screen.dart';

class PriceEstimateScreen extends StatefulWidget {
  const PriceEstimateScreen({super.key, required this.booking});

  static const String routeName = '/parcel/estimate';

  final ParcelBooking booking;

  @override
  State<PriceEstimateScreen> createState() => _PriceEstimateScreenState();
}

class _PriceEstimateScreenState extends State<PriceEstimateScreen> {
  ParcelQuote? _quote;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quote = await ParcelsApi.quote(
        distanceKm: widget.booking.distanceKm,
        weightKg: widget.booking.weightKg,
        priority: widget.booking.priority,
      );
      if (!mounted) return;
      widget.booking.quote = quote;
      setState(() {
        _quote = quote;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _confirm() {
    final quote = _quote;
    if (quote == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParcelSummaryScreen(booking: widget.booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final booking = widget.booking;
    final quote = _quote;
    final distanceCharge = quote == null ? 0.0 : booking.distanceKm * quote.perKm;
    final weightCharge = quote == null ? 0.0 : booking.weightKg * quote.perKg;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(
                title: 'Price Estimate',
                subtitle: 'Step 4 of 5',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                TextButton(onPressed: _loadQuote, child: const Text('Retry')),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _StatBlock(
                                          icon: Icons.route_outlined,
                                          label: 'Distance',
                                          value: '${booking.distanceKm.toStringAsFixed(1)} km',
                                        ),
                                      ),
                                      Container(width: 1, height: 44, color: AppColors.cardBorder),
                                      Expanded(
                                        child: _StatBlock(
                                          icon: Icons.scale_outlined,
                                          label: 'Weight',
                                          value: '${booking.weightKg.toStringAsFixed(1)} kg',
                                        ),
                                      ),
                                      Container(width: 1, height: 44, color: AppColors.cardBorder),
                                      Expanded(
                                        child: _StatBlock(
                                          icon: Icons.inventory_2_outlined,
                                          label: 'Type',
                                          value: booking.parcelType ?? 'Box',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text('Fare breakdown', style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Column(
                                    children: [
                                      _FareRow(label: 'Base fare', value: quote!.base),
                                      const SizedBox(height: 12),
                                      _FareRow(label: 'Distance charge', value: distanceCharge),
                                      const SizedBox(height: 12),
                                      _FareRow(label: 'Weight charge', value: weightCharge),
                                      if (quote.multiplier != 1) ...[
                                        const SizedBox(height: 12),
                                        _FareRow(
                                          label: '${statusLabel(quote.priority)} rate',
                                          value: quote.multiplier,
                                          isMultiplier: true,
                                        ),
                                      ],
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        child: Divider(height: 1, color: AppColors.cardBorder),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Fare',
                                            style: textTheme.titleLarge?.copyWith(fontSize: 18),
                                          ),
                                          Text(
                                            '৳${quote.fare.toStringAsFixed(0)}',
                                            style: textTheme.titleLarge?.copyWith(
                                              fontSize: 18,
                                              color: AppColors.primaryNavy,
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
              const SizedBox(height: 12),
              PrimaryButton(
                label: quote == null ? 'Fetching fare…' : 'Confirm',
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: quote == null ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryNavy),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({required this.label, required this.value, this.isMultiplier = false});

  final String label;
  final double value;
  final bool isMultiplier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyLarge),
        Text(
          isMultiplier ? '×${value.toStringAsFixed(2)}' : '৳${value.toStringAsFixed(0)}',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
