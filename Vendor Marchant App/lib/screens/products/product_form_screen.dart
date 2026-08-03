import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../services/api/api_client.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../utils/product_validators.dart';
import '../../widgets/common_widgets.dart';

class _PickedImage {
  const _PickedImage({
    required this.path,
    required this.bytes,
    required this.name,
  });

  final String path;
  final Uint8List bytes;
  final String name;
}

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
  String _category = '';
  bool _trackStock = true;
  int _stock = 0;
  List<String> _images = [];
  final List<_PickedImage> _localImages = [];
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

  static const _maxImageBytes = 5 * 1024 * 1024;

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image must be 5 MB or smaller')),
      );
      return;
    }
    setState(() {
      _localImages.add(_PickedImage(
        path: file.path,
        bytes: bytes,
        name: file.name.isNotEmpty ? file.name : 'product.jpg',
      ));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductsProvider>();
    final existing = widget.isEdit ? provider.findById(widget.productId!) : null;
    final picked = _localImages.isNotEmpty ? _localImages.first : null;
    final product = ProductModel(
      id: existing?.id ?? '',
      name: _name.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      categoryId: provider.categoryIdForName(_category),
      price: double.tryParse(_price.text) ?? 0,
      sku: _sku.text.trim(),
      stock: _stock,
      lowStockAlert: int.tryParse(_lowStock.text) ?? 5,
      trackStock: _trackStock,
      imageUrls: _images,
      localImagePath: picked?.path,
      localImageBytes: picked?.bytes,
      localImageName: picked?.name,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save product'),
        ),
      );
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
                      bytes: _localImages.isNotEmpty
                          ? _localImages.first.bytes
                          : null,
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
                    validator: ProductValidators.required,
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
                    validator: ProductValidators.required,
                  ),
                  const SizedBox(height: 12),
                  Text('Category', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(                    value: categories.contains(_category) ? _category : null,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                    decoration: const InputDecoration(),
                  ),
                  const SizedBox(height: 12),
                  Text('Price (BDT)', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: '৳ '),
                    validator: ProductValidators.price,
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
                    validator: ProductValidators.required,
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
  const _PhotoBox({this.url, this.bytes, this.onTap, this.small = false});

  final String? url;
  final Uint8List? bytes;
  final VoidCallback? onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (bytes != null) {
      child = Image.memory(bytes!, fit: BoxFit.cover);
    } else if (url != null) {
      final resolved = ApiClient.absoluteUrl(url) ?? url!;
      child = Image.network(resolved, fit: BoxFit.cover);
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
