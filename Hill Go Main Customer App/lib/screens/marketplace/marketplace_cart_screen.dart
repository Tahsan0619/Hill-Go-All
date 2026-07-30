import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/demo_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';

class MarketplaceCartScreen extends StatefulWidget {
  const MarketplaceCartScreen({super.key});

  static const String routeName = '/market/cart';

  @override
  State<MarketplaceCartScreen> createState() => _MarketplaceCartScreenState();
}

class _MarketplaceCartScreenState extends State<MarketplaceCartScreen> {
  List<CartLine> get _lines => MarketplaceCartStore.lines;

  double get _subtotal => MarketplaceCartStore.subtotal;
  double get _deliveryFee => _lines.isEmpty ? 0 : 3.99;
  double get _total => _subtotal + _deliveryFee;

  void _updateQuantity(CartLine line, int delta) {
    setState(() {
      final newQuantity = line.quantity + delta;
      if (newQuantity <= 0) {
        final index = MarketplaceCartStore.lines.indexOf(line);
        MarketplaceCartStore.removeAt(index);
      } else {
        line.quantity = newQuantity;
      }
    });
  }

  void _checkout() {
    MarketplaceCartStore.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully'),
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lines = _lines;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: AppBackBar(
                title: 'My Cart',
                subtitle: '${lines.length} items',
              ),
            ),
            Expanded(
              child: lines.isEmpty
                  ? Center(
                      child: Text('Your cart is empty', style: textTheme.bodyLarge),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      itemCount: lines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final line = lines[index];
                        return _CartLineTile(
                          line: line,
                          onIncrement: () => _updateQuantity(line, 1),
                          onDecrement: () => _updateQuantity(line, -1),
                        );
                      },
                    ),
            ),
            if (lines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: '\$${_subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Delivery', value: '\$${_deliveryFee.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Total',
                      value: '\$${_total.toStringAsFixed(2)}',
                      bold: true,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Checkout',
                      backgroundColor: AppColors.accentOrange,
                      borderRadius: 14,
                      onPressed: _checkout,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartLine line;
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
          AppNetworkImage(
            imageUrl: line.product.imageUrl,
            width: 64,
            height: 64,
            borderRadius: BorderRadius.circular(12),
            fallbackColor: line.product.imageColor,
            fallbackIcon: line.product.icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${line.product.price.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${line.quantity}', style: textTheme.bodyLarge),
              ),
              _QtyButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
