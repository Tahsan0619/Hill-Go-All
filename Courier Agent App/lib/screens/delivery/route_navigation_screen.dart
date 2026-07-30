import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/parcel_model.dart';
import '../../providers/parcel_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_map.dart';
import '../../widgets/common_widgets.dart';

class RouteNavigationScreen extends StatefulWidget {
  const RouteNavigationScreen({super.key, required this.parcelId});
  final String parcelId;

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen> {
  final _mapController = MapController();
  bool _satelliteStyle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ParcelProvider>();
      if (provider.selected?.id != widget.parcelId) {
        provider.loadParcel(widget.parcelId);
      }
    });
  }

  Future<void> _call(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(uri) && await launchUrl(uri)) {
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the phone app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HillGoAppBar(
      showBack: true,
      title: 'Navigation',
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: () => context.push('/support'),
      ),
    ),
    body: Consumer<ParcelProvider>(
      builder: (context, provider, _) {
        if (provider.detailState == LoadState.loading &&
            provider.selected == null) {
          return const LoadingView(message: 'Preparing your route...');
        }
        if (provider.selected == null) {
          return ErrorView(
            message: provider.error ?? 'We could not prepare this route.',
            onRetry: () => provider.loadParcel(widget.parcelId),
          );
        }
        return _routeView(provider.selected!);
      },
    ),
  );

  Widget _routeView(ParcelModel parcel) {
    final center = LatLng(
      (parcel.pickup.latitude + parcel.dropoff.latitude) / 2,
      (parcel.pickup.longitude + parcel.dropoff.longitude) / 2,
    );
    return Stack(
      children: [
        AppMapView(
          center: center,
          mapController: _mapController,
          height: double.infinity,
          zoom: 13,
          borderRadius: BorderRadius.zero,
          route: [parcel.pickup, parcel.dropoff],
          markers: [
            pinMarker(
              parcel.pickup,
              color: AppColors.primary,
              icon: Icons.delivery_dining_rounded,
            ),
            pinMarker(
              parcel.dropoff,
              color: AppColors.accent,
              icon: Icons.location_on_rounded,
            ),
          ],
        ),
        Positioned(
          top: AppSpacing.lg,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.turn_right_rounded, color: Colors.white, size: 32),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Turn right onto Broadway',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.screenPadding,
          top: 95,
          child: Column(
            children: [
              _MapButton(
                icon: Icons.layers_outlined,
                onTap: () {
                  setState(() => _satelliteStyle = !_satelliteStyle);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_satelliteStyle ? 'Satellite' : 'Standard'} map style selected.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _MapButton(
                icon: Icons.my_location_rounded,
                onTap: () => _mapController.move(center, 13),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MapButton(
                icon: Icons.add_rounded,
                onTap: () => _mapController.move(center, 14),
              ),
              const SizedBox(height: AppSpacing.xs),
              _MapButton(
                icon: Icons.remove_rounded,
                onTap: () => _mapController.move(center, 12),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.screenPadding),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED ARRIVAL', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${parcel.etaMinutes} min • ${parcel.distanceKm.toStringAsFixed(1)} km',
                    style: AppTextStyles.h2,
                  ),
                  const Divider(height: AppSpacing.xxl),
                  Text(parcel.orderId, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          parcel.receiverAddress,
                          style: AppTextStyles.body,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _call(parcel.receiverPhone),
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/support'),
                    icon: const Icon(Icons.support_agent_outlined),
                    label: const Text('Contact Support'),
                  ),
                  PrimaryButton(
                    label: 'Arrived at Dropoff',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () =>
                        context.push('/parcel/${parcel.id}/delivery-otp'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, color: AppColors.primary),
      ),
    ),
  );
}
