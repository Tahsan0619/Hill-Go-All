import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
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
  bool _promoApplied = false;

  static const double _deliveryFee = 30;
  static const double _promoDiscount = 25;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    if (_promoController.text.trim().isEmpty) return;
    setState(() => _promoApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promo code applied!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = FoodCartStore.lines;
    final subtotal = FoodCartStore.subtotal;
    final total = subtotal + _deliveryFee - (_promoApplied ? _promoDiscount : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Your cart'),
      body: lines.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: Theme.of(context).textTheme.bodyLarge),
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
                      onIncrement: () => setState(() => line.quantity++),
                      onDecrement: () => setState(() {
                        if (line.quantity > 1) {
                          line.quantity--;
                        } else {
                          FoodCartStore.removeAt(index);
                        }
                      }),
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
                            hintText: 'Enter promo code',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _applyPromo,
                        child: Text(_promoApplied ? 'Applied' : 'Apply'),
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
                      FareRow(label: 'Subtotal', value: 'à§³${subtotal.toStringAsFixed(0)}'),
                      FareRow(label: 'Delivery fee', value: 'à§³${_deliveryFee.toStringAsFixed(0)}'),
                      if (_promoApplied)
                        FareRow(
                          label: 'Promo discount',
                          value: '-à§³${_promoDiscount.toStringAsFixed(0)}',
                          valueColor: AppColors.brandLime,
                        ),
                      const Divider(color: AppColors.inputBorder, height: 24),
                      FareRow(label: 'Total', value: 'à§³${total.toStringAsFixed(0)}', isTotal: true),
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
                label: 'Checkout â€¢ à§³${total.toStringAsFixed(0)}',
                backgroundColor: AppColors.primaryNavy,
                borderRadius: 14,
                onPressed: () => Navigator.of(context).pushNamed(FoodCheckoutScreen.routeName),
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
                Text('à§³${line.item.price.toStringAsFixed(0)} each', style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
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
