import '../models/catalog_models.dart';
import 'api/api_client.dart';

/// Authenticated customer from GET /customer/me.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.language = 'en',
    this.districtId,
    this.districtName,
    this.customerCode,
    this.tier = 'Bronze',
    this.walletBalance = 0,
    this.loyaltyPoints = 0,
    this.ordersCount = 0,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String language;
  final String? districtId;
  final String? districtName;
  final String? customerCode;
  final String tier;
  final double walletBalance;
  final int loyaltyPoints;
  final int ordersCount;

  String get phoneDisplay => phone;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return AuthUser(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar'] as String?,
      language: (json['language'] as String?) ?? 'en',
      districtId: json['district_id']?.toString(),
      districtName: json['district'] as String?,
      customerCode: profile is Map ? profile['code'] as String? : null,
      tier: profile is Map ? (profile['tier'] as String?) ?? 'Bronze' : 'Bronze',
      walletBalance: profile is Map ? asDouble(profile['wallet_balance']) : 0,
      loyaltyPoints: profile is Map ? asInt(profile['loyalty_points']) : 0,
      ordersCount: profile is Map ? asInt(profile['orders_count']) : 0,
    );
  }
}

/// Session + auth flows backed by the HillGo API (Sanctum bearer tokens).
class AuthService {
  AuthService._();

  static AuthUser? _currentUser;
  static String? _pendingPhone;

  static bool get isLoggedIn => _currentUser != null;

  /// Current user. Only valid after a successful login / session restore.
  static AuthUser get user =>
      _currentUser ??
      const AuthUser(id: 0, name: '', phone: '');

  static String? get pendingPhone => _pendingPhone;

  /// Restores the session from a persisted token. Returns true when a valid
  /// session exists.
  static Future<bool> restoreSession() async {
    await ApiClient.loadToken();
    if (!ApiClient.hasToken) return false;
    try {
      final data = await ApiClient.get('/customer/me');
      _currentUser = AuthUser.fromJson(data as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      if (e.isUnauthorized) return false;
      // Network trouble: keep the token but do not report a live session.
      return false;
    }
  }

  /// Refreshes the cached user from GET /customer/me.
  static Future<AuthUser?> refreshUser() async {
    if (!ApiClient.hasToken) return null;
    final data = await ApiClient.get('/customer/me');
    _currentUser = AuthUser.fromJson(data as Map<String, dynamic>);
    return _currentUser;
  }

  // ── Phone OTP login ──────────────────────────────────────────────────────

  /// Step 1: request an OTP for an existing customer's phone.
  static Future<void> requestLoginOtp(String phone) async {
    await ApiClient.post('/customer/auth/otp/request', body: {'phone': phone});
    _pendingPhone = phone;
    _pendingRegistration = null;
  }

  /// Step 2: verify the OTP → token + user.
  static Future<AuthUser> verifyLoginOtp(String phone, String otp) async {
    final data = await ApiClient.post(
      '/customer/auth/otp/verify',
      body: {'phone': phone, 'otp': otp},
    ) as Map<String, dynamic>;
    return _adoptSession(data);
  }

  // ── Email/password login ─────────────────────────────────────────────────

  static Future<AuthUser> loginWithEmail(String email, String password) async {
    final data = await ApiClient.post(
      '/customer/auth/login',
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;
    return _adoptSession(data);
  }

  // ── Registration (OTP-first) ─────────────────────────────────────────────

  static Map<String, dynamic>? _pendingRegistration;

  static bool get hasPendingRegistration => _pendingRegistration != null;

  /// Step 1: submit registration details; the backend sends an OTP.
  static Future<void> startRegistration({
    required String name,
    required String phone,
    String? email,
    String? districtId,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (districtId != null && districtId.isNotEmpty)
        'district_id': districtId,
    };
    await ApiClient.post('/customer/auth/register', body: payload);
    _pendingRegistration = payload;
    _pendingPhone = phone;
  }

  /// Step 2: repeat the registration call with the OTP → token + user.
  static Future<AuthUser> completeRegistration(String otp) async {
    final payload = _pendingRegistration;
    if (payload == null) {
      throw const ApiException('No registration in progress.');
    }
    final data = await ApiClient.post(
      '/customer/auth/register',
      body: {...payload, 'otp': otp},
    ) as Map<String, dynamic>;
    _pendingRegistration = null;
    return _adoptSession(data);
  }

  // ── Session ──────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    try {
      await ApiClient.post('/customer/auth/logout');
    } on ApiException {
      // Token may already be invalid; clear locally regardless.
    }
    await ApiClient.clearToken();
    _currentUser = null;
    _pendingPhone = null;
    _pendingRegistration = null;
    FoodCartStore.clear();
    MarketplaceCartStore.clear();
  }

  static Future<AuthUser> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? language,
  }) async {
    final data = await ApiClient.patch('/customer/me', body: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (language != null) 'language': language,
    }) as Map<String, dynamic>;
    _currentUser = AuthUser.fromJson(data);
    return _currentUser!;
  }

  static Future<AuthUser> _adoptSession(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Login failed: no token returned.');
    }
    await ApiClient.setToken(token);
    _currentUser =
        AuthUser.fromJson((data['user'] as Map<String, dynamic>?) ?? {});
    _pendingPhone = null;
    return _currentUser!;
  }
}
