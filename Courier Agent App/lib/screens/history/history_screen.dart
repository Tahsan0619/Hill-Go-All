import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/parcel_model.dart';
import '../../providers/parcel_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<ParcelProvider>().loadHistory(); });
  }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HillGoAppBar(showMenu: true, onBell: () => context.push('/notifications')),
    body: Consumer<ParcelProvider>(builder: (context, provider, _) {
      if (provider.historyState == LoadState.loading) return const LoadingView(message: 'Loading delivery history...');
      if (provider.historyState == LoadState.error) return ErrorView(message: provider.error ?? 'Could not load history.', onRetry: provider.loadHistory);
      return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        TextField(
          controller: _search,
          onSubmitted: (query) => provider.loadHistory(query: query),
          decoration: InputDecoration(
            hintText: 'Search Order ID', prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: () => provider.loadHistory(query: _search.text)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: ['daily', 'weekly', 'monthly'].map((period) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: period == 'monthly' ? 0 : 8),
            child: ChoiceChip(
              label: Text('${period[0].toUpperCase()}${period.substring(1)}'),
              selected: provider.historyPeriod == period,
              onSelected: (_) => provider.loadHistory(period: period),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: provider.historyPeriod == period ? Colors.white : AppColors.textSecondary),
            ),
          ),
        )).toList()),
        const SizedBox(height: AppSpacing.lg),
        AppCard(color: AppColors.primary, child: Row(children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TOTAL EARNINGS', style: AppTextStyles.label.copyWith(color: Colors.white70)),
            Text('৳${provider.historyTotal.toStringAsFixed(2)}', style: AppTextStyles.amount.copyWith(color: Colors.white)),
          ])),
          StatusChip(label: '${provider.history.length} of ${provider.historyTotalCount}', fg: const Color(0xFF12623B), bg: const Color(0xFFC9F7D8)),
        ])),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Recent Deliveries'),
        const SizedBox(height: AppSpacing.sm),
        if (provider.history.isEmpty)
          const SizedBox(height: 260, child: EmptyView(message: 'No deliveries match your filters.'))
        else ...[
          ...provider.history.map(_deliveryCard),
          const SizedBox(height: AppSpacing.sm),
          if (provider.hasMoreHistory)
            PrimaryButton(
              label: 'View More History',
              loading: provider.loadingMore,
              onPressed: provider.loadingMore ? null : provider.loadMoreHistory,
              icon: Icons.expand_more_rounded,
            ),
        ],
      ]);
    }),
  );

  Widget _deliveryCard(ParcelModel parcel) {
    final delivered = parcel.status == ParcelStatus.delivered;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () => context.push('/parcel/${parcel.id}'),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: delivered ? AppColors.successBg : AppColors.errorBg,
            child: Icon(delivered ? Icons.check_circle_outline : Icons.error_outline, color: delivered ? AppColors.success : AppColors.error),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(parcel.orderId, style: AppTextStyles.h3),
            Text(DateFormat('MMM d, h:mm a').format(parcel.completedAt ?? parcel.createdAt), style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(parcel.receiverName, style: AppTextStyles.bodySecondary),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusChip(label: delivered ? 'DELIVERED' : 'FAILED', fg: delivered ? AppColors.success : AppColors.error, bg: delivered ? AppColors.successBg : AppColors.errorBg),
            const SizedBox(height: 7),
            Text('৳${(parcel.payout ?? 0).toStringAsFixed(2)}', style: AppTextStyles.amountSm),
          ]),
        ]),
      ),
    );
  }
}
