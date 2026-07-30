import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  bool get isEdit => productId != null && productId != 'new';

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _price;
  late TextEditingController _sku;
  late TextEditingController _lowStock;
  String _category = 'Bakery';
  bool _trackStock = true;
  int _stock = 0;
  List<String> _images = [];
  final List<String> _localImages = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _desc = TextEditingController();
    _price = TextEditingController();
    _sku = TextEditingController();
    _lowStock = TextEditingController(text: '5');
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final provider = context.read<ProductsProvider>();
    if (provider.products.isEmpty) {
      provider.load().then((_) {
        if (mounted) _fillFromProduct();
      });
    } else {
      _fillFromProduct();
    }
  }

  void _fillFromProduct() {
    if (_initialized) return;
    final provider = context.read<ProductsProvider>();
    if (widget.isEdit) {
      final p = provider.findById(widget.productId!);
      if (p != null) {
        _name.text = p.name;
        _desc.text = p.description;
        _price.text = p.price.toStringAsFixed(2);
        _sku.text = p.sku;
        _lowStock.text = '${p.lowStockAlert}';
        _category = p.category;
        _trackStock = p.trackStock;
        _stock = p.stock;
        _images = List.from(p.imageUrls);
      }
    } else if (provider.categories.isNotEmpty) {
      _category = provider.categories.first.name;
    }
    _initialized = true;
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _sku.dispose();
    _lowStock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _localImages.add(file.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductsProvider>();
    final existing = widget.isEdit ? provider.findById(widget.productId!) : null;
    final product = ProductModel(
      id: existing?.id ?? provider.newBlankProduct().id,
      name: _name.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      price: double.tryParse(_price.text) ?? 0,
      sku: _sku.text.trim(),
      stock: _stock,
      lowStockAlert: int.tryParse(_lowStock.text) ?? 5,
      trackStock: _trackStock,
      imageUrls: _images.isNotEmpty
          ? _images
          : [
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
            ],
    );
    final ok = await provider.saveProduct(product);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Product updated' : 'Product created'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final categories = provider.categories.map((c) => c.name).toList();
    if (categories.isNotEmpty && !categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.isEdit ? 'Edit Product' : 'Add Product',
              style: AppTextStyles.h1,
            ),
            Text(
              widget.isEdit
                  ? 'Update your product details and stock information.'
                  : 'Create a new listing for your store.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 16),
            Text('PRODUCT PHOTOS', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _PhotoBox(
                      url: _images.isNotEmpty ? _images.first : null,
                      local: _localImages.isNotEmpty ? _localImages.first : null,
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _PhotoBox(
                                  url: _images.length > 1 ? _images[1] : null,
                                  onTap: _pickImage,
                                  small: true,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add_a_photo_outlined),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.textMuted,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Text(
                                'Add more angles',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Name',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Description',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _desc,
                    maxLines: 3,
                    decoration: const InputDecoration(),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Category', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: categories.contains(_category) ? _category : null,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                    decoration: const InputDecoration(),
                  ),
                  const SizedBox(height: 12),
                  Text('Price (USD)', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: '\$ '),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid price';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventory Management', style: AppTextStyles.h3),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Track Stock'),
                    value: _trackStock,
                    onChanged: (v) => setState(() => _trackStock = v),
                  ),
                  Text('SKU / Item Code', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _sku,
                    decoration: const InputDecoration(),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Current Stock', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: () => setState(
                          () => _stock = (_stock - 1).clamp(0, 99999),
                        ),
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_stock', style: AppTextStyles.h3),
                      ),
                      IconButton.outlined(
                        onPressed: () => setState(() => _stock++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Low Stock Alert Level', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _lowStock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Save Changes',
                    loading: provider.isSaving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({this.url, this.local, this.onTap, this.small = false});

  final String? url;
  final String? local;
  final VoidCallback? onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (local != null) {
      child = Image.file(File(local!), fit: BoxFit.cover);
    } else if (url != null) {
      child = Image.network(url!, fit: BoxFit.cover);
    } else {
      child = Container(
        color: const Color(0xFFEEEEEE),
        child: const Icon(Icons.image_outlined),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
