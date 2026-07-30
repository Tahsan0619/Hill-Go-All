import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Row describing a single wallet transaction.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.amount,
    this.isCredit = false,
    this.icon = Icons.receipt_long_outlined,
  });

  final String title;
  final String dateLabel;
  final double amount;
  final bool isCredit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amountColor = isCredit ? const Color(0xFF2E9E44) : AppColors.textPrimary;
    final sign = isCredit ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFE8F8EB) : AppColors.accentOrangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isCredit ? const Color(0xFF2E9E44) : AppColors.accentOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(dateLabel, style: textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '$sign\$${amount.toStringAsFixed(2)}',
            style: textTheme.bodyLarge?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
