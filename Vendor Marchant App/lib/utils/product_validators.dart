/// Pure validation helpers for the product form, extracted from
/// `ProductFormScreen` so the rules can be unit-tested without pumping a
/// widget tree.
class ProductValidators {
  ProductValidators._();

  static const double minPrice = 0;
  static const double maxPrice = 1e7;

  /// Returns an error message, or `null` when [value] is a non-blank string.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  /// Validates the product price field: required, numeric, and within
  /// `[minPrice, maxPrice]`.
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Invalid price';
    if (parsed < minPrice || parsed > maxPrice) {
      return 'Price must be between 0 and 10,000,000';
    }
    return null;
  }
}
