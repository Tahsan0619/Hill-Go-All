import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/parcel_model.dart';
import '../../providers/parcel_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_map.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/otp_input.dart';

enum OtpMode { pickup, delivery }

class OtpConfirmationScreen extends StatefulWidget {
  const OtpConfirmationScreen({
    super.key,
    required this.parcelId,
    required this.mode,
  });

  final String parcelId;
  final OtpMode mode;

  @override
  State<OtpConfirmationScreen> createState() => _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState extends State<OtpConfirmationScreen> {
  String _otp = '';
  bool _submitting = false;

  bool get _isPickup => widget.mode == OtpMode.pickup;
  String get _personLabel => _isPickup ? 'Sender' : 'Receiver';

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

  Future<void> _confirm() async {
    if (_otp.length != 4) {
      return;
    }
    setState(() => _submitting = true);
    final provider = context.read<ParcelProvider>();
    final success = _isPickup
        ? await provider.confirmPickup(_otp)
        : await provider.confirmDelivery(_otp);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (success) {
      context.go(
        '/parcel/${widget.parcelId}/${_isPickup ? 'navigate' : 'success'}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Unable to confirm the OTP.')),
      );
    }
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

  /// Photo proof for when the counterpart cannot provide the OTP
  /// (audited alternative — `POST /courier/parcels/{id}/proof`).
  Future<void> _uploadPhotoProof() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    final provider = context.read<ParcelProvider>();
    final ok = await provider.uploadProof(type: 'photo', filePath: image.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Proof photo uploaded. Support will review the delivery.'
            : (provider.error ?? 'Could not upload the proof photo.')),
      ),
    );
  }

  void _showAlternatives() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alternative confirmation', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              _AlternativeTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take photo of package',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _uploadPhotoProof();
                },
              ),
              _AlternativeTile(
                icon: Icons.support_agent_outlined,
                label: 'Contact support',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/support');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HillGoAppBar(
        showBack: true,
        title: _isPickup ? 'Pickup Confirmation' : 'Delivery Confirmation',
      ),
      body: Consumer<ParcelProvider>(
        builder: (context, provider, _) {
          if (provider.detailState == LoadState.loading &&
              provider.selected == null) {
            return const LoadingView(message: 'Loading task...');
          }
          final parcel = provider.selected;
          if (parcel == null) {
            return ErrorView(
              message: provider.error ?? 'We could not load this parcel.',
              onRetry: () => provider.loadParcel(widget.parcelId),
            );
          }
          return _buildContent(parcel);
        },
      ),
    );
  }

  Widget _buildContent(ParcelModel parcel) {
    final taskPoint = _isPickup ? parcel.pickup : parcel.dropoff;
    final personName = _isPickup ? parcel.senderName : parcel.receiverName;
    final phone = _isPickup ? parcel.senderPhone : parcel.receiverPhone;
    final address = _isPickup ? parcel.senderAddress : parcel.receiverAddress;
    final title = _isPickup ? 'Pickup OTP' : 'Delivery OTP';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          AppMapView(
            center: taskPoint,
            height: 180,
            zoom: 15,
            markers: [
              pinMarker(
                taskPoint,
                color: _isPickup ? AppColors.primary : AppColors.accent,
              ),
            ],
            children: [
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT TASK',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        _isPickup
                            ? 'At Pickup Location'
                            : 'At Delivery Location',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    personName.isEmpty ? '?' : personName[0].toUpperCase(),
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(
                        label: _personLabel.toUpperCase(),
                        fg: AppColors.primary,
                        bg: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(personName, style: AppTextStyles.h3),
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${parcel.orderId} • ${parcel.type}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(title, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.xs),
          Text('Ask for the 4-digit code', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          OtpInputRow(
            length: 4,
            onChanged: (value) => setState(() => _otp = value),
            onCompleted: (value) => setState(() => _otp = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Confirm ${_isPickup ? 'Pickup' : 'Delivery'}',
            loading: _submitting,
            enabled: _otp.length == 4,
            color: _isPickup ? AppColors.primary : AppColors.accent,
            onPressed: _confirm,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _call(phone),
            icon: const Icon(Icons.phone_outlined),
            label: Text('Call $_personLabel'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          TextButton(
            onPressed: _showAlternatives,
            child: Text('$_personLabel doesn\'t have OTP?'),
          ),
        ],
      ),
    );
  }
}

class _AlternativeTile extends StatelessWidget {
  const _AlternativeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(label, style: AppTextStyles.body),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
