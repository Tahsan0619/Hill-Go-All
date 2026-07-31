import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/food_api.dart';
import '../../services/api/profile_api.dart';
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
  bool _placing = false;

  List<SavedAddress> _addresses = [];
  int _addressIndex = 0;
  bool _addressesLoading = true;
  final _addressController = TextEditingController();

  static const _paymentMethods = [
    {'label': 'Cash on Delivery', 'icon': Icons.payments_outlined, 'value': 'cash'},
    {'label': 'HillGo Wallet', 'icon': Icons.account_balance_wallet_outlined, 'value': 'wallet'},
    {'label': 'Card', 'icon': Icons.credit_card, 'value': 'card'},
  ];

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
      setState(() {
        _addresses = rows;
        _addressesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _addressesLoading = false);
    }
  }

  String? get _deliveryAddress {
    if (_addresses.isNotEmpty) {
      final selected = _addresses[_addressIndex.clamp(0, _addresses.length - 1)];
      return '${selected.label}: ${selected.address}';
    }
    final manual = _addressController.text.trim();
    return manual.isEmpty ? null : manual;
  }

  Future<void> _placeOrder() async {
    final storeId = FoodCartStore.restaurantId;
    final address = _deliveryAddress;
    if (storeId == null) {
      _snack('Your cart is empty.');
      return;
    }
    if (address == null) {
      _snack('Please enter a delivery address.');
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final promoCode = args is Map ? args['promo_code'] as String? : null;

    setState(() => _placing = true);
    try {
      final order = await FoodApi.checkout(
        storeId: storeId,
        lines: FoodCartStore.lines,
        deliveryAddress: address,
        paymentMethod: _paymentMethods[_paymentIndex]['value'] as String,
        promoCode: promoCode,
      );
      FoodCartStore.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        OrderTrackingScreen.routeName,
        arguments: order,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      _snack(e.message);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtotal = FoodCartStore.subtotal;

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
            if (_addressesLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
              )
            else if (_addresses.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  controller: _addressController,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: List.generate(_addresses.length, (index) {
                    final address = _addresses[index];
                    return RadioListTile<int>(
                      value: index,
                      groupValue: _addressIndex,
                      onChanged: (value) => setState(() => _addressIndex = value ?? 0),
                      activeColor: AppColors.primaryNavy,
                      title: Text(
                        address.label,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        address.address,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }),
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
                  for (final line in FoodCartStore.lines)
                    FareRow(
                      label: '${line.item.name} ×${line.quantity}',
                      value: '৳${line.lineTotal.toStringAsFixed(0)}',
                    ),
                  const Divider(color: AppColors.inputBorder, height: 24),
                  FareRow(label: 'Subtotal', value: '৳${subtotal.toStringAsFixed(0)}', isTotal: true),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Delivery fee and any promo discount are confirmed by the restaurant when the order is placed.',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
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
          label: _placing ? 'Placing order…' : 'Place Order',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: _placing ? null : _placeOrder,
        ),
      ),
    );
  }
}
