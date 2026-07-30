import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/demo_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/transaction_tile.dart';
import 'payment_method_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.showBack = true});

  static const String routeName = '/wallet';

  final bool showBack;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DemoAuthService.user;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBack)
                AppBackBar(
                  title: 'My Wallet',
                  actions: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodScreen(),
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.credit_card_outlined,
                          color: AppColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Text(
                      'HillGo Wallet',
                      style: textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        PaymentMethodScreen.routeName,
                      ),
                      icon: const Icon(
                        Icons.credit_card_outlined,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              if (showBack) const SizedBox(height: 8),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryNavy, Color(0xFF00306B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${user.walletBalance.toStringAsFixed(2)}',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 34,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _WalletActionButton(
                            icon: Icons.add,
                            label: 'Add Money',
                            onTap: () => _snack(context, 'Add money to wallet'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _WalletActionButton(
                            icon: Icons.north_east,
                            label: 'Send',
                            onTap: () => _snack(context, 'Send money'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Transactions',
                style: textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: dummyTransactions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.cardBorder),
                  itemBuilder: (context, index) {
                    final transaction = dummyTransactions[index];
                    return TransactionTile(
                      title: transaction.title,
                      dateLabel: transaction.dateLabel,
                      amount: transaction.amount,
                      isCredit: transaction.isCredit,
                      icon: transaction.icon,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  const _WalletActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
