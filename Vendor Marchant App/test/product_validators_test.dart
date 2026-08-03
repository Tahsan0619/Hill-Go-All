import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_marchant_app/utils/product_validators.dart';

void main() {
  group('ProductValidators.required', () {
    test('rejects null', () {
      expect(ProductValidators.required(null), 'Required');
    });

    test('rejects empty/whitespace', () {
      expect(ProductValidators.required(''), 'Required');
      expect(ProductValidators.required('   '), 'Required');
    });

    test('accepts non-blank text', () {
      expect(ProductValidators.required('Chicken Biryani'), isNull);
    });
  });

  group('ProductValidators.price', () {
    test('rejects null/empty', () {
      expect(ProductValidators.price(null), 'Required');
      expect(ProductValidators.price(''), 'Required');
    });

    test('rejects non-numeric input', () {
      expect(ProductValidators.price('abc'), 'Invalid price');
    });

    test('rejects negative price', () {
      expect(ProductValidators.price('-5'), isNotNull);
    });

    test('rejects price above the 10,000,000 ceiling', () {
      expect(ProductValidators.price('10000001'), isNotNull);
    });

    test('accepts zero (free item)', () {
      expect(ProductValidators.price('0'), isNull);
    });

    test('accepts a normal decimal price', () {
      expect(ProductValidators.price('249.50'), isNull);
    });

    test('accepts the upper boundary', () {
      expect(ProductValidators.price('10000000'), isNull);
    });
  });
}
