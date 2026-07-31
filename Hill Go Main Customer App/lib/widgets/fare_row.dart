import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A label/value row used inside fare breakdowns, order summaries and
/// checkout screens.
class FareRow extends StatelessWidget {
  const FareRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )
                : textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: isTotal
                ? textTheme.bodyLarge?.copyWith(
                    color: valueColor ?? AppColors.primaryNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )
                : textTheme.bodyLarge?.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
