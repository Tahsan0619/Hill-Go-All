import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/marketplace_api.dart';
import '../../services/api/profile_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/hillgo_cart_logo.dart';
import '../../widgets/primary_button.dart';

class MarketplaceCartScreen extends StatefulWidget {
  const MarketplaceCartScreen({super.key});

  static const String routeName = '/market/cart';

  @override
  State<MarketplaceCartScreen> createState() => _MarketplaceCartScreenState();
}

class _MarketplaceCartScreenState extends State<MarketplaceCartScreen> {
  bool _checkingOut = false;
  String _paymentMethod = 'cash';
  final _addressController = TextEditingController();
  List<SavedAddress> _addresses = [];
  int _addressIndex = 0;

  List<CartLine> get _lines => MarketplaceCartStore.lines;
  double get _subtotal => MarketplaceCartStore.subtotal;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final rows = await ProfileApi.addresses();
      if (!mounted) return;
      setState(() => _addresses = rows);
    } catch (_) {
      // Manual address entry remains available.
    }
  }

  void _updateQuantity(CartLine line, int delta) {
    final index = MarketplaceCartStore.lines.indexOf(line);
    if (index < 0) return;
    setState(() {
      MarketplaceCartStore.setQuantity(index, line.quantity + delta);
    });
  }

  String? get _deliveryAddress {
    if (_addresses.isNotEmpty) {
      final selected = _addresses[_addressIndex.clamp(0, _addresses.length - 1)];
      return '${selected.label}: ${selected.address}';
    }
    final manual = _addressController.text.trim();
    return manual.isEmpty ? null : manual;
  }

  Future<void> _checkout() async {
    final address = _deliveryAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address.')),
      );
      return;
    }
    setState(() => _checkingOut = true);
    try {
      await MarketplaceApi.checkout(
        lines: MarketplaceCartStore.lines,
        deliveryAddress: address,
        paymentMethod: _paymentMethod,
      );
      MarketplaceCartStore.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _checkingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.accentBlueSoft,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            alignment: Alignment.center,
                            child: const HillGoCartLogo(size: 44),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: textTheme.titleLarge?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Browse the marketplace to add products.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      children: [
                        ...List.generate(lines.length, (index) {
                          final line = lines[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CartLineTile(
                              line: line,
                              onIncrement: () => _updateQuantity(line, 1),
                              onDecrement: () => _updateQuantity(line, -1),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text('Delivery address', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if (_addresses.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                hintText: 'Enter delivery address',
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        else
                          ...List.generate(_addresses.length, (index) {
                            final address = _addresses[index];
                            return RadioListTile<int>(
                              value: index,
                              groupValue: _addressIndex,
                              onChanged: (v) => setState(() => _addressIndex = v ?? 0),
                              activeColor: AppColors.primaryNavy,
                              title: Text(address.label),
                              subtitle: Text(address.address),
                            );
                          }),
                        const SizedBox(height: 12),
                        Text('Pay with', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                        RadioListTile<String>(
                          value: 'cash',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                          activeColor: AppColors.primaryNavy,
                          title: const Text('Cash on Delivery'),
                        ),
                        RadioListTile<String>(
                          value: 'wallet',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v ?? 'wallet'),
                          activeColor: AppColors.primaryNavy,
                          title: const Text('HillGo Wallet'),
                        ),
                        RadioListTile<String>(
                          value: 'card',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v ?? 'card'),
                          activeColor: AppColors.primaryNavy,
                          title: const Text('Card'),
                        ),
                      ],
                    ),
            ),
            if (lines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: '৳${_subtotal.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    const _SummaryRow(label: 'Delivery', value: 'Confirmed at checkout'),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Items total',
                      value: '৳${_subtotal.toStringAsFixed(0)}',
                      bold: true,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _checkingOut ? 'Placing order…' : 'Checkout',
                      backgroundColor: AppColors.accentOrange,
                      borderRadius: 14,
                      onPressed: _checkingOut ? null : _checkout,
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
                  '৳${line.product.price.toStringAsFixed(0)}',
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
