import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/primary_button.dart';
import 'food_cart_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  static const String routeName = '/food/item';

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    FoodMenuItem? item;
    int? restaurantId;
    String restaurantName = '';
    if (args is Map) {
      if (args['item'] is FoodMenuItem) item = args['item'] as FoodMenuItem;
      if (args['restaurantId'] is int) restaurantId = args['restaurantId'] as int;
      if (args['restaurantName'] is String) restaurantName = args['restaurantName'] as String;
    }

    final textTheme = Theme.of(context).textTheme;

    if (item == null || restaurantId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Item')),
        body: Center(child: Text('Item not found.', style: textTheme.bodyLarge)),
      );
    }

    final resolvedItem = item;
    final resolvedRestaurantId = restaurantId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: resolvedItem.color,
            expandedHeight: 260,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CartIconButton(
                  size: 40,
                  iconSize: 20,
                  showMarket: false,
                  backgroundColor: AppColors.white,
                  borderColor: Colors.transparent,
                  onTap: () => Navigator.of(context).pushNamed(FoodCartScreen.routeName),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                imageUrl: resolvedItem.imageUrl,
                fallbackColor: resolvedItem.color,
                fallbackIcon: resolvedItem.icon,
                fallbackIconSize: 96,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          resolvedItem.name,
                          style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                        ),
                      ),
                      Text(
                        '৳${resolvedItem.price.toStringAsFixed(0)}',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 22, color: AppColors.primaryNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('From $restaurantName', style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Text(
                    resolvedItem.description,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            _StepperButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
          label: 'Add to Cart • ৳${(resolvedItem.price * _quantity).toStringAsFixed(0)}',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: () {
            FoodCartStore.add(resolvedItem, resolvedRestaurantId, restaurantName, quantity: _quantity);
            Navigator.of(context).maybePop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${resolvedItem.name} added to cart'), duration: const Duration(seconds: 1)),
            );
          },
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.primaryNavy, size: 18),
      ),
    );
  }
}
