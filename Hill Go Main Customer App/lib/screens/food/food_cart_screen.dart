import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/hillgo_cart_logo.dart';
import '../../widgets/primary_button.dart';
import 'food_checkout_screen.dart';

class FoodCartScreen extends StatefulWidget {
  const FoodCartScreen({super.key});

  static const String routeName = '/food/cart';

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}

class _FoodCartScreenState extends State<FoodCartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = FoodCartStore.lines;
    final subtotal = FoodCartStore.subtotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Your cart'),
      body: lines.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrangeSoft,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: const HillGoCartLogo(size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add dishes from a restaurant to continue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...List.generate(lines.length, (index) {
                  final line = lines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FoodCartLineTile(
                      line: line,
                      onRemove: () => setState(() => FoodCartStore.removeAt(index)),
                      onIncrement: () => setState(
                        () => FoodCartStore.setQuantity(index, line.quantity + 1),
                      ),
                      onDecrement: () => setState(
                        () => FoodCartStore.setQuantity(index, line.quantity - 1),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, color: AppColors.accentOrange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Promo code (applied at checkout)',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      FareRow(label: 'Subtotal', value: '৳${subtotal.toStringAsFixed(0)}'),
                      const FareRow(label: 'Delivery fee', value: 'Calculated at checkout'),
                      const Divider(color: AppColors.inputBorder, height: 24),
                      FareRow(label: 'Items total', value: '৳${subtotal.toStringAsFixed(0)}', isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
                ],
              ),
              child: PrimaryButton(
                label: 'Checkout • ৳${subtotal.toStringAsFixed(0)}',
                backgroundColor: AppColors.primaryNavy,
                borderRadius: 14,
                onPressed: () => Navigator.of(context).pushNamed(
                  FoodCheckoutScreen.routeName,
                  arguments: {'promo_code': _promoController.text.trim()},
                ),
              ),
            ),
    );
  }
}

class _FoodCartLineTile extends StatelessWidget {
  const _FoodCartLineTile({
    required this.line,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final FoodCartLine line;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: line.item.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(line.item.icon, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('৳${line.item.price.toStringAsFixed(0)} each', style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(onTap: onRemove, child: const Icon(Icons.close, size: 18, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MiniStepper(icon: Icons.remove, onTap: onDecrement),
                  SizedBox(
                    width: 24,
                    child: Text('${line.quantity}', textAlign: TextAlign.center, style: textTheme.bodyMedium),
                  ),
                  _MiniStepper(icon: Icons.add, onTap: onIncrement),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, size: 14, color: AppColors.primaryNavy),
      ),
    );
  }
}
