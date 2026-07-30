import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../services/demo_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/page_indicator.dart';
import '../../widgets/primary_button.dart';
import 'marketplace_cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  static const String routeName = '/market/product';

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _pageController = PageController();
  int _galleryIndex = 0;
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _addToCart() {
    MarketplaceCartStore.add(widget.product, quantity: _quantity);
    _snack('Added ${_quantity}x ${widget.product.name} to cart');
  }

  void _buyNow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MarketplaceCartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: AppBackBar(title: product.category),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _galleryIndex = index),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return AppNetworkImage(
                            imageUrl: product.imageUrl,
                            borderRadius: BorderRadius.circular(20),
                            fallbackColor: product.imageColor,
                            fallbackIcon: product.icon,
                            fallbackIconSize: 88,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: PageIndicator(count: 3, currentIndex: _galleryIndex),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Description', style: textTheme.titleLarge?.copyWith(fontSize: 17)),
                    const SizedBox(height: 8),
                    Text(product.description, style: textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity', style: textTheme.titleLarge?.copyWith(fontSize: 17)),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.inputBorder),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_quantity > 1) setState(() => _quantity--);
                                },
                                icon: const Icon(Icons.remove, size: 18),
                                color: AppColors.textPrimary,
                              ),
                              Text(
                                '$_quantity',
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _quantity++),
                                icon: const Icon(Icons.add, size: 18),
                                color: AppColors.textPrimary,
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
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Add to Cart',
                      backgroundColor: AppColors.accentOrange,
                      borderRadius: 14,
                      height: 52,
                      onPressed: _addToCart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Buy Now',
                      backgroundColor: AppColors.primaryNavy,
                      borderRadius: 14,
                      height: 52,
                      onPressed: _buyNow,
                    ),
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
