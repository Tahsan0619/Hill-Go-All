import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_marchant_app/services/api/api_client.dart';

void main() {
  group('ApiException', () {
    test('isUnauthorized when status is 401', () {
      final e = ApiException(401, 'gone');
      expect(e.isUnauthorized, isTrue);
      expect(e.isNotFound, isFalse);
      expect(e.toString(), 'gone');
    });

    test('isNotFound when status is 404', () {
      final e = ApiException(404, 'missing');
      expect(e.isNotFound, isTrue);
      expect(e.isUnauthorized, isFalse);
    });

    test('carries field errors when provided', () {
      final e = ApiException(422, 'Validation failed', errors: {
        'price': ['Price must be between 0 and 10,000,000'],
      });
      expect(e.errors, isNotNull);
      expect(e.errors!['price'], contains('Price must be between 0 and 10,000,000'));
    });
  });

  group('ApiClient.absoluteUrl', () {
    test('leaves absolute http(s) URLs unchanged', () {
      expect(
        ApiClient.absoluteUrl('https://cdn.example/a.png'),
        'https://cdn.example/a.png',
      );
      expect(
        ApiClient.absoluteUrl('http://cdn.example/a.png'),
        'http://cdn.example/a.png',
      );
    });

    test('returns null for null/empty input', () {
      expect(ApiClient.absoluteUrl(null), isNull);
      expect(ApiClient.absoluteUrl(''), isNull);
    });

    test('prefixes a relative storage path with the API origin', () {
      final url = ApiClient.absoluteUrl('/storage/products/x.jpg');
      expect(url, isNotNull);
      expect(url!.endsWith('/storage/products/x.jpg'), isTrue);
      expect(url.contains('://'), isTrue);
    });

    test('inserts a separating slash when the path is missing one', () {
      final url = ApiClient.absoluteUrl('storage/products/x.jpg');
      expect(url, isNotNull);
      expect(url!.endsWith('/storage/products/x.jpg'), isTrue);
    });
  });
}
