import '../../models/models.dart';
import '../auth_repository.dart';
import 'api_client.dart';

/// Rider auth + profile against the HillGo Laravel backend (Sanctum).
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;
  List<DistrictOption>? _districtsCache;
  DateTime? _districtsCachedAt;

  /// Districts change rarely (region-lock rollout); refetch at most hourly.
  static const Duration _districtsTtl = Duration(hours: 1);

  /// Normalizes any user-entered BD number to the +880XXXXXXXXXX form so
  /// registration and OTP login always address the same account.
  static String normalizeBdPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('880')) return '+$digits';
    if (digits.startsWith('0')) return '+88$digits';
    return '+880$digits';
  }

  @override
  Future<DriverUser?> getCurrentSession() async {
    if (!_client.hasToken) return null;
    try {
      final json = await _client.get('/rider/me');
      return DriverUser.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null; // token already cleared by client
      rethrow;
    }
  }

  @override
  Future<DriverUser> login({required String email, required String password}) async {
    final identifier = email.trim();
    final json = await _client.post('/rider/auth/login', body: {
      if (identifier.contains('@'))
        'email': identifier.toLowerCase()
      else
        'phone': normalizeBdPhone(identifier),
      'password': password,
    }) as Map<String, dynamic>;
    await _client.saveToken(json['token'] as String);
    invalidateDistrictsCache();
    return DriverUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> requestOtp({required String emailOrPhone}) async {
    await _client.post('/rider/auth/otp/request', body: {
      'phone': normalizeBdPhone(emailOrPhone),
    });
  }

  @override
  Future<DriverUser> verifyOtp({required String emailOrPhone, required String code}) async {
    final json = await _client.post('/rider/auth/otp/verify', body: {
      'phone': normalizeBdPhone(emailOrPhone),
      'otp': code.trim(),
    }) as Map<String, dynamic>;
    await _client.saveToken(json['token'] as String);
    invalidateDistrictsCache();
    return DriverUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<DriverUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final json = await _client.post('/rider/auth/register', body: {
      'name': name.trim(),
      'phone': normalizeBdPhone(phone),
      if (email.trim().isNotEmpty) 'email': email.trim().toLowerCase(),
      'password': password,
    }) as Map<String, dynamic>;
    await _client.saveToken(json['token'] as String);
    invalidateDistrictsCache();
    return DriverUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordReset({required String phone}) async {
    await _client.post('/rider/auth/password/forgot', body: {
      'phone': normalizeBdPhone(phone),
    });
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _client.post('/rider/auth/password/reset', body: {
      'phone': normalizeBdPhone(phone),
      'otp': code.trim(),
      'password': newPassword,
    });
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/rider/auth/logout');
    } on ApiException {
      // Token is invalid or already revoked — proceed with local sign-out.
    } finally {
      await _client.clearToken();
    }
  }

  @override
  Future<void> updateProfile(DriverUser user) async {
    await _client.patch('/rider/me', body: {
      'name': user.name,
      'phone': user.phone,
      if (user.email.isNotEmpty) 'email': user.email,
    });
  }

  @override
  Future<void> saveVehicle(VehicleInfo vehicle) async {
    await _client.put('/rider/vehicle', body: {
      'vehicle_type': vehicleCategoryToApi(vehicle.category),
      'vehicle_make': vehicle.make,
      'vehicle_model': vehicle.model,
      'vehicle_year': vehicle.year,
      'plate': vehicle.plate,
    });
  }

  @override
  Future<void> submitPersonalInfo({
    required String legalName,
    required String homeAddress,
    required String districtId,
    required String dob,
    required String nid,
  }) async {
    await _client.patch('/rider/onboarding/personal', body: {
      'legal_name': legalName,
      'home_address': homeAddress,
      'district_id': districtId,
      'dob': dob,
      'nid': nid,
    });
  }

  @override
  Future<List<DistrictOption>> getDistricts() async {
    final cache = _districtsCache;
    final cachedAt = _districtsCachedAt;
    final isFresh = cache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _districtsTtl;
    if (isFresh) return cache;

    final json = await _client.get('/public/districts') as List<dynamic>;
    _districtsCache = json
        .map((d) => DistrictOption.fromJson(d as Map<String, dynamic>))
        .toList();
    _districtsCachedAt = DateTime.now();
    return _districtsCache!;
  }

  @override
  void invalidateDistrictsCache() {
    _districtsCache = null;
    _districtsCachedAt = null;
  }

  @override
  Future<void> completeOnboarding() async {
    await _client.post('/rider/onboarding/complete');
  }

  @override
  Future<void> setOnboardingStep(OnboardingStep step) async {
    // Client-side navigation state only — the backend derives onboarding
    // progress from the saved profile data.
  }
}
