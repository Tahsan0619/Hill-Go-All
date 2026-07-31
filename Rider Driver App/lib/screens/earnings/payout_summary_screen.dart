import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/driver_provider.dart';
import '../../theme/colors.dart';
import '../../services/fare_config.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class PayoutSummaryScreen extends StatefulWidget {
  const PayoutSummaryScreen({super.key});

  @override
  State<PayoutSummaryScreen> createState() => _PayoutSummaryScreenState();
}

class _PayoutSummaryScreenState extends State<PayoutSummaryScreen> {
  String _period = 'weekly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final e = driver.earnings;

    double amount;
    String label;
    switch (_period) {
      case 'daily':
        amount = e?.todayTotal ?? 0;
        label = 'Daily earnings';
      case 'monthly':
        amount = (e?.currentBalance ?? 0) * 1.8;
        label = 'Monthly earnings (est.)';
      default:
        amount = (e?.baseFare ?? 0) + (e?.tips ?? 0) + (e?.surgeBonuses ?? 0);
        label = 'Weekly earnings';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Summary'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'daily', label: Text('Daily')),
              ButtonSegment(value: 'weekly', label: Text('Weekly')),
              ButtonSegment(value: 'monthly', label: Text('Monthly')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 20),
          SectionCard(
            leftAccent: AppColors.accentLime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTextStyles.labelCaps),
                const SizedBox(height: 8),
                Text(formatTaka(amount), style: AppTextStyles.moneyMd),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Payout history', style: AppTextStyles.titleBlue),
          const SizedBox(height: 10),
          if (driver.payouts.isEmpty)
            const EmptyView(title: 'No payouts yet', subtitle: 'Completed cash outs will appear here.')
          else
            ...driver.payouts.map(
              (p) => SectionCard(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.cardBlueTint,
                      child: Icon(Icons.account_balance, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatTaka(p.amount), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                          Text('${p.method} • ${DateFormat.yMMMd().format(p.date)}', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text(p.status, style: AppTextStyles.label.copyWith(color: AppColors.onlineGreen)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
