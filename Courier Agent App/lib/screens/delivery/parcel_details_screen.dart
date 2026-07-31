import 'package:flutter/material.dart';
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

class ParcelDetailsScreen extends StatefulWidget {
  const ParcelDetailsScreen({super.key, required this.parcelId});

  final String parcelId;

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ParcelProvider>().loadParcel(widget.parcelId),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HillGoAppBar(
        showBack: true,
        title: 'Parcel Details',
        onBell: () => context.push('/notifications'),
      ),
      body: Consumer<ParcelProvider>(
        builder: (context, provider, _) {
          if (provider.detailState == LoadState.loading) {
            return const LoadingView(message: 'Loading parcel details...');
          }
          if (provider.detailState == LoadState.error ||
              provider.selected == null) {
            return ErrorView(
              message: provider.error ?? 'We could not load this parcel.',
              onRetry: () => provider.loadParcel(widget.parcelId),
            );
          }
          return _ParcelDetailsBody(parcel: provider.selected!, onCall: _call);
        },
      ),
    );
  }
}

class _ParcelDetailsBody extends StatelessWidget {
  const _ParcelDetailsBody({required this.parcel, required this.onCall});

  final ParcelModel parcel;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (parcel.pickup.latitude + parcel.dropoff.latitude) / 2,
      (parcel.pickup.longitude + parcel.dropoff.longitude) / 2,
    );
    final isPickedUp =
        parcel.status == ParcelStatus.pickedUp ||
        parcel.status == ParcelStatus.inTransit;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMapView(
            center: center,
            height: 230,
            zoom: 13,
            route: [parcel.pickup, parcel.dropoff],
            markers: [
              pinMarker(
                parcel.pickup,
                color: AppColors.primary,
                icon: Icons.store_rounded,
              ),
              pinMarker(
                parcel.dropoff,
                color: AppColors.accent,
                icon: Icons.location_on_rounded,
              ),
            ],
            children: [
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: _MapOverlay(
                  label: 'ESTIMATED TIME',
                  value: '${parcel.etaMinutes} min',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionLabel('Delivery Points'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                _ContactPoint(
                  label: 'SENDER',
                  name: parcel.senderName,
                  address: parcel.senderAddress,
                  phone: parcel.senderPhone,
                  icon: Icons.storefront_rounded,
                  onCall: onCall,
                ),
                const Divider(height: AppSpacing.xxl, color: AppColors.divider),
                _ContactPoint(
                  label: 'RECEIVER',
                  name: parcel.receiverName,
                  address: parcel.receiverAddress,
                  phone: parcel.receiverPhone,
                  icon: Icons.location_on_rounded,
                  onCall: onCall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accentSoft,
                  foregroundColor: AppColors.accent,
                  child: Icon(Icons.inventory_2_outlined),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parcel Type', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${parcel.type} • ${parcel.weightKg.toStringAsFixed(1)} kg',
                        style: AppTextStyles.h3,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ORDER ID', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(parcel.orderId, style: AppTextStyles.h3),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            color: AppColors.primaryDark,
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED EARNINGS',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '৳${(parcel.estimatedEarnings + parcel.surgeBonus).toStringAsFixed(2)}',
                        style: AppTextStyles.amount.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (parcel.surgeBonus > 0)
                  StatusChip(
                    label: '+৳${parcel.surgeBonus.toStringAsFixed(2)} SURGE',
                    fg: AppColors.primaryDark,
                    bg: AppColors.accentSoft,
                  ),
              ],
            ),
          ),
          if (parcel.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Delivery Notes'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      parcel.notes,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: isPickedUp ? 'Continue Trip' : 'Start Trip',
            icon: Icons.navigation_rounded,
            onPressed: () => context.push(
              isPickedUp
                  ? '/parcel/${parcel.id}/navigate'
                  : '/parcel/${parcel.id}/pickup-otp',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _MapOverlay extends StatelessWidget {
  const _MapOverlay({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.h3),
      ],
    ),
  );
}

class _ContactPoint extends StatelessWidget {
  const _ContactPoint({
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
    required this.icon,
    required this.onCall,
  });
  final String label, name, address, phone;
  final IconData icon;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.primary),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text(name, style: AppTextStyles.h3),
            const SizedBox(height: 2),
            Text(address, style: AppTextStyles.bodySecondary),
            TextButton.icon(
              onPressed: () => onCall(phone),
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: Text(phone),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
