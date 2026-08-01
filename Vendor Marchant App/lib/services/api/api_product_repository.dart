import '../../models/product_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response =
        await _api.get('/merchant/products', query: {'per_page': '50'})
            as Map<String, dynamic>;
    return ((response['data'] as List?) ?? const [])
        .map((p) => ProductModel.fromJson(
              p as Map<String, dynamic>,
              resolveUrl: ApiClient.absoluteUrl,
            ))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response =
        await _api.get('/merchant/categories', query: {'per_page': '50'})
            as List;
    return response
        .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> saveProduct(ProductModel product) async {
    final fields = <String, String>{
      'name': product.name,
      'description': product.description,
      'price': product.price.toString(),
      'sku': product.sku,
      'stock': product.stock.toString(),
      'low_stock_alert': product.lowStockAlert.toString(),
      'track_stock': product.trackStock ? '1' : '0',
      'status': product.status,
      if (product.categoryId != null) 'category_id': product.categoryId!,
    };

    Map<String, dynamic> response;
    final hasImage = product.localImageBytes != null ||
        product.localImagePath != null;
    if (hasImage) {
      // Multipart create, or multipart-friendly POST update.
      final path = product.isNew
          ? '/merchant/products'
          : '/merchant/products/${product.id}';
      response = await _api.multipart(
        path,
        fields: fields,
        files: {
          if (product.localImageBytes == null && product.localImagePath != null)
            'image': product.localImagePath!,
        },
        fileBytes: {
          if (product.localImageBytes != null)
            'image': (
              product.localImageBytes!,
              product.localImageName ?? 'product.jpg',
            ),
        },
      ) as Map<String, dynamic>;
    } else {
      final body = <String, dynamic>{
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'sku': product.sku,
        'stock': product.stock,
        'low_stock_alert': product.lowStockAlert,
        'track_stock': product.trackStock,
        'status': product.status,
        if (product.categoryId != null)
          'category_id': int.tryParse(product.categoryId!),
      };
      response = product.isNew
          ? await _api.post('/merchant/products', body) as Map<String, dynamic>
          : await _api.patch('/merchant/products/${product.id}', body)
              as Map<String, dynamic>;
    }
    return ProductModel.fromJson(response, resolveUrl: ApiClient.absoluteUrl);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _api.delete('/merchant/products/$id');
  }

  @override
  Future<CategoryModel> addCategory(String name) async {
    final response = await _api.post('/merchant/categories', {
      'name': name,
      'icon': 'category',
      'is_visible': true,
    }) as Map<String, dynamic>;
    return CategoryModel.fromJson(response);
  }

  @override
  Future<void> setCategoryVisibility(String id, bool visible) async {
    await _api.patch('/merchant/categories/$id', {'is_visible': visible});
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await _api.post('/merchant/categories/reorder', {
      'order': orderedIds.map(int.parse).toList(),
    });
  }
}
