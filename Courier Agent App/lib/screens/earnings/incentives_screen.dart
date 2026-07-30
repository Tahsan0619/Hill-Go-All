import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/profile_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final offers = context.watch<ProfileProvider>().incentives;
    return Scaffold(
      appBar: const HillGoAppBar(title: 'Incentives', showBack: true, showBell: false),
      body: offers.isEmpty
          ? const EmptyView(message: 'There are no active incentives right now.', icon: Icons.bolt_outlined)
          : ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
              Text('Earn more for the deliveries you already make.', style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              ...offers.map((offer) => _offerCard(context, offer)),
            ]),
    );
  }

  Widget _offerCard(BuildContext context, IncentiveOffer offer) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(backgroundColor: AppColors.accentSoft, child: Icon(Icons.bolt, color: AppColors.accent)),
        const SizedBox(width: 12),
        Expanded(child: Text(offer.title, style: AppTextStyles.h3)),
        StatusChip(label: '${offer.multiplier.toStringAsFixed(1)}X', fg: AppColors.accent, bg: AppColors.accentSoft),
      ]),
      const SizedBox(height: 12),
      Text(offer.description, style: AppTextStyles.bodySecondary),
      const SizedBox(height: 8),
      Text('Valid until ${DateFormat('MMM d').format(offer.validUntil)}', style: AppTextStyles.caption),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => _details(context, offer), child: const Text('View details'))),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton(
          onPressed: offer.isActive ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${offer.title} accepted!'))) : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Accept'),
        )),
      ]),
    ])),
  );

  void _details(BuildContext context, IncentiveOffer offer) => showModalBottomSheet<void>(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(offer.title, style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Text(offer.description, style: AppTextStyles.bodySecondary),
        const SizedBox(height: 16),
        Text('Multiplier: ${offer.multiplier.toStringAsFixed(1)}x', style: AppTextStyles.h3),
      ]),
    ),
  );
}
