import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/earnings_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class IncentivesScreen extends StatefulWidget {
  const IncentivesScreen({super.key});
  @override
  State<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends State<IncentivesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EarningsProvider>().loadIncentives();
    });
  }

  Future<void> _accept(IncentiveOffer offer) async {
    final earnings = context.read<EarningsProvider>();
    final ok = await earnings.acceptIncentive(offer);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '${offer.title} accepted — deliver ${offer.goalDeliveries} to earn ৳${offer.bonusTk.toStringAsFixed(0)}.'
            : (earnings.error ?? 'Could not accept the incentive.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HillGoAppBar(title: 'Incentives', showBack: true, showBell: false),
      body: Consumer<EarningsProvider>(builder: (context, provider, _) {
        if (provider.state == EarningsLoadState.loading) {
          return const LoadingView(message: 'Loading incentives...');
        }
        if (provider.state == EarningsLoadState.error) {
          return ErrorView(message: provider.error ?? 'Could not load incentives.', onRetry: provider.loadIncentives);
        }
        final offers = provider.incentives;
        if (offers.isEmpty) {
          return const EmptyView(message: 'There are no active incentives right now.', icon: Icons.bolt_outlined);
        }
        return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
          Text('Earn more for the deliveries you already make.', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          ...offers.map((offer) => _offerCard(context, offer)),
        ]);
      }),
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
      Text(
        'Deliver ${offer.goalDeliveries} parcels · ৳${offer.bonusTk.toStringAsFixed(0)} bonus'
        '${offer.validUntil == null ? '' : ' · Valid until ${DateFormat('MMM d').format(offer.validUntil!)}'}',
        style: AppTextStyles.caption,
      ),
      if (offer.accepted) ...[
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progress', style: AppTextStyles.caption),
          Text('${offer.progress} / ${offer.goalDeliveries}', style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: offer.goalDeliveries == 0 ? 0 : (offer.progress / offer.goalDeliveries).clamp(0.0, 1.0),
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
          color: AppColors.accent,
          backgroundColor: AppColors.accentSoft,
        ),
      ],
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => _details(context, offer), child: const Text('View details'))),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton(
          onPressed: offer.isActive && !offer.accepted ? () => _accept(offer) : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(offer.accepted ? 'Accepted' : 'Accept'),
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
        const SizedBox(height: 6),
        Text('Goal: ${offer.goalDeliveries} deliveries · Bonus: ৳${offer.bonusTk.toStringAsFixed(0)}', style: AppTextStyles.body),
        if ((offer.district ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('District: ${offer.district}', style: AppTextStyles.body),
        ],
      ]),
    ),
  );
}
