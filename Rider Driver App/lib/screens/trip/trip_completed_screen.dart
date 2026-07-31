import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/fare_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({super.key, this.trip});

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final t = trip;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xl * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Job Completed',
                          style: AppTextStyles.display.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t == null
                              ? 'Great work — earnings were added to your balance.'
                              : '${t.jobType.label} to ${t.dropoffName} finished successfully.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 28),
                        if (t != null)
                          SectionCard(
                            leftAccent: AppColors.accentLime,
                            child: Column(
                              children: [
                                _row('Job fare', formatTaka(t.earning)),
                                if (t.tip > 0) _row('Tip', formatTaka(t.tip)),
                                const Divider(height: 20),
                                _row('Total', formatTaka(t.total), bold: true),
                                const SizedBox(height: 8),
                                _row('Distance', formatKm(t.distanceKm)),
                                _row('Duration', '${t.durationMin} min'),
                                _row('Customer', t.customerName),
                                if (t.isCod) _row('Payment', 'COD collected'),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        AccentButton(
                          label: 'Back to Home',
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: 10),
                        if (t != null)
                          OutlinedButton(
                            onPressed: () => context.push('/trip/details/${t.id}'),
                            child: const Text('View Job Details'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(
            value,
            style: bold
                ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)
                : AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
