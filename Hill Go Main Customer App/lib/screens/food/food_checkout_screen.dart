import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/demo_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import 'order_tracking_screen.dart';

class FoodCheckoutScreen extends StatefulWidget {
  const FoodCheckoutScreen({super.key});

  static const String routeName = '/food/checkout';

  @override
  State<FoodCheckoutScreen> createState() => _FoodCheckoutScreenState();
}

class _FoodCheckoutScreenState extends State<FoodCheckoutScreen> {
  int _paymentIndex = 0;

  static const _paymentMethods = [
    {'label': 'Cash on Delivery', 'icon': Icons.payments_outlined},
    {'label': 'HillGo Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Card', 'icon': Icons.credit_card},
  ];

  static const double _deliveryFee = 30;

  void _placeOrder() {
    FoodCartStore.clear();
    Navigator.of(context).pushReplacementNamed(OrderTrackingScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = DemoAuthService.user;
    final address = dummyAddresses.first;
    final subtotal = FoodCartStore.subtotal;
    final total = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery address', style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, color: AppColors.primaryNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.label, style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${user.name} · ${address.address}',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/profile/addresses'),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Payment method', style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: List.generate(_paymentMethods.length, (index) {
                  final method = _paymentMethods[index];
                  final selected = index == _paymentIndex;
                  return RadioListTile<int>(
                    value: index,
                    groupValue: _paymentIndex,
                    onChanged: (value) => setState(() => _paymentIndex = value ?? 0),
                    activeColor: AppColors.primaryNavy,
                    secondary: Icon(method['icon'] as IconData, color: selected ? AppColors.primaryNavy : AppColors.textMuted),
                    title: Text(
                      method['label'] as String,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Text('Order summary', style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  FareRow(label: 'Subtotal', value: 'à§³${subtotal.toStringAsFixed(0)}'),
                  FareRow(label: 'Delivery fee', value: 'à§³${_deliveryFee.toStringAsFixed(0)}'),
                  const Divider(color: AppColors.inputBorder, height: 24),
                  FareRow(label: 'Total', value: 'à§³${total.toStringAsFixed(0)}', isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
          ],
        ),
        child: PrimaryButton(
          label: 'Place Order',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: _placeOrder,
        ),
      ),
    );
  }
}
