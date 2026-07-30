import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/products_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductsProvider>();
      if (p.categories.isEmpty) p.load();
    });
  }

  Future<void> _addCategory() async {
    final ctrl = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Category', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Category name'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Create',
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            ),
          ],
        ),
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      await context.read<ProductsProvider>().addCategory(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "$name" created')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final cats = provider.filteredCategories;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: _addCategory,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoading && cats.isEmpty
          ? const LoadingView()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: AppTextStyles.h1),
                      Text(
                        'Manage your product groups and visibility.',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 12),
                      SearchField(
                        hint: 'Search categories...',
                        onChanged: provider.setCategorySearch,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: cats.isEmpty
                      ? const EmptyView(message: 'No categories found.')
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cats.length + 1,
                          onReorder: (oldIndex, newIndex) {
                            if (oldIndex >= cats.length ||
                                newIndex > cats.length) {
                              return;
                            }
                            provider.reorderCategories(oldIndex, newIndex);
                          },
                          itemBuilder: (_, i) {
                            if (i == cats.length) {
                              return Container(
                                key: const ValueKey('info'),
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Dragging to reorder will change how your customers see categories on your store profile. Changes are saved automatically.',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final cat = cats[i];
                            return Padding(
                              key: ValueKey(cat.id),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                onTap: () {
                                  provider.setCategoryFilter(cat.name);
                                  context.pop();
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: cat.color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(cat.icon,
                                          color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cat.name,
                                              style: AppTextStyles.bodyBold),
                                          Text(
                                            '${cat.itemCount} Items',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: cat.isVisible,
                                      onChanged: (v) => provider
                                          .toggleCategoryVisibility(cat.id, v),
                                    ),
                                    ReorderableDragStartListener(
                                      index: i,
                                      child: const Icon(
                                        Icons.drag_indicator,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
