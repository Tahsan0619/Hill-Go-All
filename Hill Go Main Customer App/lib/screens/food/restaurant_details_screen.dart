import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/food_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/food_item_tile.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/view_cart_bar.dart';
import 'food_cart_screen.dart';
import 'food_details_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({super.key, this.restaurant});

  static const String routeName = '/food/restaurant';

  final RestaurantInfo? restaurant;

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  RestaurantInfo? _restaurant;
  bool _menuLoading = true;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    _restaurant = widget.restaurant ?? (args is RestaurantInfo ? args : null);
    if (_restaurant != null) {
      _loadMenu();
    } else {
      _menuLoading = false;
    }
  }

  Future<void> _loadMenu() async {
    final base = _restaurant;
    if (base == null) return;
    setState(() {
      _menuLoading = true;
      _error = null;
    });
    try {
      final full = await FoodApi.restaurant(base.id);
      if (!mounted) return;
      setState(() {
        _restaurant = full;
        _menuLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _menuLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _restaurant;
    final textTheme = Theme.of(context).textTheme;

    if (resolved == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Restaurant')),
        body: Center(child: Text('Restaurant not found.', style: textTheme.bodyLarge)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: resolved.color,
            expandedHeight: 200,
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
                  iconSize: 18,
                  showMarket: false,
                  backgroundColor: AppColors.white,
                  borderColor: Colors.transparent,
                  iconColor: AppColors.textPrimary,
                  onTap: () => Navigator.of(context).pushNamed(FoodCartScreen.routeName),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                imageUrl: resolved.imageUrl,
                fallbackColor: resolved.color,
                fallbackIcon: Icons.storefront,
                fallbackIconSize: 72,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolved.name,
                    style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(resolved.cuisine, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStars(rating: resolved.rating, size: 16),
                      const SizedBox(width: 6),
                      Text(resolved.rating.toStringAsFixed(1), style: textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(resolved.time, style: textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      const Icon(Icons.delivery_dining, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('৳${resolved.fee.toStringAsFixed(0)} delivery', style: textTheme.bodyMedium),
                    ],
                  ),
                  if (!resolved.acceptingOrders) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrangeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'This restaurant is not accepting orders right now.',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_menuLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingView(),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: LoadErrorView(message: _error!, onRetry: _loadMenu),
            )
          else if (resolved.menu.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(
                icon: Icons.restaurant_menu,
                message: 'No menu items available yet.',
              ),
            )
          else
            for (final category in resolved.menu) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Text(
                    category.name,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: category.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = category.items[index];
                    return FoodItemTile(
                      name: item.name,
                      description: item.description,
                      price: item.price,
                      color: item.color,
                      icon: item.icon,
                      imageUrl: item.imageUrl,
                      onTap: () => Navigator.of(context).pushNamed(
                        FoodDetailsScreen.routeName,
                        arguments: {
                          'item': item,
                          'restaurantId': resolved.id,
                          'restaurantName': resolved.name,
                        },
                      ),
                      onAdd: () {
                        FoodCartStore.add(item, resolved.id, resolved.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} added to cart'), duration: const Duration(seconds: 1)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: FoodCartStore.revision,
        builder: (context, _) {
          return ViewCartBar(
            itemCount: FoodCartStore.itemCount,
            subtotal: FoodCartStore.subtotal,
            label: FoodCartStore.restaurantName == null
                ? 'View cart'
                : 'View cart · ${FoodCartStore.restaurantName}',
            onTap: () => Navigator.of(context).pushNamed(FoodCartScreen.routeName),
          );
        },
      ),
    );
  }
}
