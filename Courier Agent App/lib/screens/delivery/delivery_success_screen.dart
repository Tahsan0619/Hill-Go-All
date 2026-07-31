import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/parcel_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class DeliverySuccessScreen extends StatefulWidget {
  const DeliverySuccessScreen({super.key, required this.parcelId});
  final String parcelId;

  @override
  State<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends State<DeliverySuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parcel = context.watch<ParcelProvider>().selected;
    final orderId = parcel?.orderId ?? widget.parcelId;
    final earnings = parcel == null
        ? null
        : parcel.estimatedEarnings + parcel.surgeBonus;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: const BoxDecoration(
                      color: AppColors.successBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 72,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Delivery Complete!',
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Order $orderId has been delivered successfully.',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppCard(
                  color: AppColors.primaryDark,
                  child: Column(
                    children: [
                      Text(
                        'EARNINGS EARNED',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        earnings == null
                            ? 'Confirmed'
                            : '৳${earnings.toStringAsFixed(2)}',
                        style: AppTextStyles.amount.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('How was this delivery?', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      tooltip: 'Rate ${index + 1} stars',
                      onPressed: () => setState(() => _rating = index + 1),
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 34,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                if (_rating > 0)
                  Text(
                    'Thanks for your $_rating-star rating!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                const Spacer(),
                PrimaryButton(
                  label: 'Done',
                  icon: Icons.dashboard_outlined,
                  onPressed: () => context.go('/dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
