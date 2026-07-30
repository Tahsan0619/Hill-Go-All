import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = provider.filteredProducts;

    return Scaffold(
      appBar: HillGoAppBar(
        title: 'HillGo',
        actions: [
          IconButton(
            tooltip: 'Categories',
            icon: const Icon(Icons.category_outlined, color: AppColors.primary),
            onPressed: () => context.push('/products/categories'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoading && provider.products.isEmpty
          ? const LoadingView()
          : provider.error != null && provider.products.isEmpty
              ? ErrorView(
                  message: provider.error!,
                  onRetry: () => context.read<ProductsProvider>().load(),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<ProductsProvider>().load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SearchField(
                        hint: 'Search products, SKU, or category...',
                        onChanged: provider.setSearch,
                      ),
                      const SizedBox(height: 12),
                      FilterChipBar(
                        items: provider.categoryNames,
                        selected: provider.categoryFilter,
                        onSelected: provider.setCategoryFilter,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL ITEMS', style: AppTextStyles.label),
                                  Text(
                                    '${provider.totalItems}',
                                    style: AppTextStyles.h1
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LOW STOCK', style: AppTextStyles.label),
                                  Text(
                                    '${provider.lowStockCount}',
                                    style: AppTextStyles.h1
                                        .copyWith(color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (products.isEmpty)
                        const EmptyView(message: 'No products match your filters.')
                      else
                        ...products.map((p) => _ProductCard(product: p)),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductsProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => context.push('/products/${product.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkThumb(
              url: product.imageUrls.isNotEmpty
                  ? product.imageUrls.first
                  : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
              size: 72,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(product.name, style: AppTextStyles.bodyBold),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'edit') {
                            context.push('/products/${product.id}');
                          } else if (v == 'delete') {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete product?'),
                                content: Text('Remove "${product.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await provider.deleteProduct(product.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product deleted'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: product.isLowStock
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isLowStock
                            ? '${product.stock} remaining'
                            : '${product.stock} in stock',
                        style: AppTextStyles.caption.copyWith(
                          color: product.isLowStock
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                      const Spacer(),
                      Text('SKU: ${product.sku}', style: AppTextStyles.caption),
                    ],
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
