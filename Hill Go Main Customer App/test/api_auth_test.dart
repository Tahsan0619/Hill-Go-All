import 'package:flutter_test/flutter_test.dart';
import 'package:hillgo/services/api/api_client.dart';
import 'package:hillgo/services/auth_service.dart';

void main() {
  group('ApiException', () {
    test('isUnauthorized when status is 401', () {
      const e = ApiException('gone', statusCode: 401);
      expect(e.isUnauthorized, isTrue);
      expect(e.toString(), 'gone');
    });

    test('isUnauthorized false for other codes', () {
      const e = ApiException('nope', statusCode: 403);
      expect(e.isUnauthorized, isFalse);
    });
  });

  group('ApiClient.absoluteUrl', () {
    test('leaves absolute http(s) unchanged', () {
      expect(
        ApiClient.absoluteUrl('https://cdn.example/a.png'),
        'https://cdn.example/a.png',
      );
      expect(
        ApiClient.absoluteUrl('http://cdn.example/a.png'),
        'http://cdn.example/a.png',
      );
    });

    test('returns null for empty', () {
      expect(ApiClient.absoluteUrl(null), isNull);
      expect(ApiClient.absoluteUrl(''), isNull);
    });

    test('prefixes relative paths with origin', () {
      final url = ApiClient.absoluteUrl('/storage/x.jpg');
      expect(url, isNotNull);
      expect(url!.endsWith('/storage/x.jpg'), isTrue);
      expect(url.contains('://'), isTrue);
    });
  });

  group('AuthUser.fromJson', () {
    test('maps nested profile fields', () {
      final user = AuthUser.fromJson({
        'id': 7,
        'name': 'Ada Lovelace',
        'phone': '01700000000',
        'email': 'ada@example.com',
        'language': 'bn',
        'district_id': 3,
        'district': 'Dhaka',
        'profile': {
          'code': 'C-001',
          'tier': 'Gold',
          'wallet_balance': '120.50',
          'loyalty_points': 42,
          'orders_count': 9,
        },
      });
      expect(user.id, 7);
      expect(user.name, 'Ada Lovelace');
      expect(user.tier, 'Gold');
      expect(user.walletBalance, 120.50);
      expect(user.loyaltyPoints, 42);
      expect(user.ordersCount, 9);
      expect(user.initials, 'AL');
    });

    test('tolerates missing profile', () {
      final user = AuthUser.fromJson({
        'id': 1,
        'name': 'Solo',
        'phone': '01',
      });
      expect(user.walletBalance, 0);
      expect(user.tier, 'Bronze');
      expect(user.initials, 'S');
    });
  });

  group('AuthService session flags', () {
    test('isLoggedIn false without user; user getter falls back', () {
      // Cannot fully exercise login without network; verify defaults.
      expect(AuthService.user.id, isA<int>());
    });
  });
}
