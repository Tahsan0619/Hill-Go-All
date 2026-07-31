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

  Future<void> _confirmDelete(ProductModel product) async {
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final provider = context.read<ProductsProvider>();
    final deleted = await provider.deleteProduct(product.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Product deleted'
              : provider.error ?? 'Failed to delete product',
        ),
      ),
    );
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
                        ...products.map(
                          (p) => _ProductCard(
                            product: p,
                            onOpen: () => context.push('/products/${p.id}'),
                            onDelete: () => _confirmDelete(p),
                          ),
                        ),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onOpen,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NetworkThumb(
                        url: product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : '',
                        size: 72,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: AppTextStyles.bodyBold),
                            const SizedBox(height: 4),
                            Text(
                              '৳${product.price.toStringAsFixed(2)}',
                              style: AppTextStyles.price,
                            ),
                            const SizedBox(height: 4),
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
                                Expanded(
                                  child: Text(
                                    product.isLowStock
                                        ? '${product.stock} remaining'
                                        : '${product.stock} in stock',
                                    style: AppTextStyles.caption.copyWith(
                                      color: product.isLowStock
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                ),
                                Text(
                                  'SKU: ${product.sku}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onOpen,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
