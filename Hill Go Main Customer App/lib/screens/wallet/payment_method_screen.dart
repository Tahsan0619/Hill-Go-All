import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';

class _PaymentMethod {
  const _PaymentMethod(this.label, this.subtitle, this.icon, this.color, this.background);

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  static const String routeName = '/wallet/payment-methods';

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selected = 'Visa •••• 4821';

  static const _methods = [
    _PaymentMethod(
      'Visa •••• 4821',
      'Expires 08/28',
      Icons.credit_card,
      AppColors.primaryNavy,
      Color(0xFFEAF1FB),
    ),
    _PaymentMethod(
      'bKash',
      '+880 1712-345678',
      Icons.phone_iphone,
      Color(0xFFE2136E),
      Color(0xFFFCE4EF),
    ),
    _PaymentMethod(
      'Nagad',
      '+880 1712-345678',
      Icons.smartphone,
      Color(0xFFF7941D),
      AppColors.accentOrangeSoft,
    ),
    _PaymentMethod(
      'Cash on Delivery',
      'Pay when you receive',
      Icons.payments_outlined,
      Color(0xFF2E9E44),
      Color(0xFFE8F8EB),
    ),
  ];

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(title: 'Payment Methods'),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    final selected = method.label == _selected;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selected = method.label),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primaryNavy : AppColors.cardBorder,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: method.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(method.icon, size: 22, color: method.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.label,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(method.subtitle, style: textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected ? AppColors.primaryNavy : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Add Method',
                icon: Icons.add,
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: () => _snack('Add a new payment method'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
