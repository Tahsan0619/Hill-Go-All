import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_driver_app/services/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiException', () {
    test('isUnauthorized is true only for 401', () {
      final unauthorized = ApiException(401, 'nope');
      final forbidden = ApiException(403, 'nope');
      expect(unauthorized.isUnauthorized, isTrue);
      expect(forbidden.isUnauthorized, isFalse);
    });

    test('toString returns the message', () {
      final e = ApiException(422, 'Validation failed');
      expect(e.toString(), 'Validation failed');
    });

    test('statusCode 0 marks a transport-level failure (no response)', () {
      final e = ApiException(0, 'Could not reach the server. Check your connection.');
      expect(e.statusCode, 0);
      expect(e.isUnauthorized, isFalse);
    });
  });

  group('ApiClient token lifecycle', () {
    setUp(() {
      // Fresh in-memory secure storage + prefs before every test so token
      // state never leaks between cases.
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
    });

    test('hasToken is false before loadToken with nothing stored', () async {
      final client = ApiClient();
      await client.loadToken();
      expect(client.hasToken, isFalse);
      expect(client.token, isNull);
    });

    test('saveToken persists to secure storage and updates in-memory state', () async {
      final client = ApiClient();
      await client.loadToken();

      await client.saveToken('abc123');

      expect(client.hasToken, isTrue);
      expect(client.token, 'abc123');
    });

    test('a fresh ApiClient instance loads a token saved by another instance', () async {
      final writer = ApiClient();
      await writer.loadToken();
      await writer.saveToken('shared-token');

      final reader = ApiClient();
      await reader.loadToken();

      expect(reader.hasToken, isTrue);
      expect(reader.token, 'shared-token');
    });

    test('clearToken removes the token from memory and secure storage', () async {
      final client = ApiClient();
      await client.loadToken();
      await client.saveToken('to-be-cleared');
      expect(client.hasToken, isTrue);

      await client.clearToken();
      expect(client.hasToken, isFalse);
      expect(client.token, isNull);

      // Confirm it is actually gone from the underlying store too, not just
      // the in-memory field.
      final reader = ApiClient();
      await reader.loadToken();
      expect(reader.hasToken, isFalse);
    });

    test('loadToken migrates a legacy SharedPreferences token into secure storage', () async {
      SharedPreferences.setMockInitialValues({'hillgo_rider_token': 'legacy-token'});

      final client = ApiClient();
      await client.loadToken();

      expect(client.hasToken, isTrue);
      expect(client.token, 'legacy-token');

      // Legacy value should have been removed after migration.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('hillgo_rider_token'), isNull);

      // And a second client should now read it straight from secure storage
      // without needing the (now-deleted) legacy prefs value.
      final reader = ApiClient();
      await reader.loadToken();
      expect(reader.hasToken, isTrue);
      expect(reader.token, 'legacy-token');
    });
  });
}
