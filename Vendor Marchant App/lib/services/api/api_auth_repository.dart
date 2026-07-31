import '../../models/user_model.dart';
import '../auth_repository.dart';
import 'api_client.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  @override
  Future<bool> isLoggedIn() async => _api.hasToken;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!_api.hasToken) return null;
    try {
      final me = await _api.get('/merchant/me') as Map<String, dynamic>;
      final onboarding = await getOnboardingStatus();
      return UserModel.fromApi(
        me,
        onboardingComplete: onboarding.submitted,
        avatarBase: ApiClient.origin,
      );
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null; // token already cleared by client
      rethrow;
    }
  }

  @override
  Future<UserModel> login(String identifier, String password) async {
    final isEmail = identifier.contains('@');
    final response = await _api.post('/merchant/auth/login', {
      if (isEmail) 'email': identifier.trim() else 'phone': identifier.trim(),
      'password': password,
    }) as Map<String, dynamic>;

    await _api.saveToken(response['token'] as String);
    final onboarding = await getOnboardingStatus();
    return UserModel.fromApi(
      response['user'] as Map<String, dynamic>,
      onboardingComplete: onboarding.submitted,
      avatarBase: ApiClient.origin,
    );
  }

  @override
  Future<RegisterResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? otp,
  }) async {
    final response = await _api.post('/merchant/auth/register', {
      'name': name.trim(),
      'phone': phone.trim(),
      if (email.trim().isNotEmpty) 'email': email.trim(),
      'password': password,
      if (otp != null && otp.isNotEmpty) 'otp': otp,
    }) as Map<String, dynamic>;

    if (response['otp_required'] == true) {
      return const RegisterResult(otpRequired: true);
    }

    await _api.saveToken(response['token'] as String);
    return RegisterResult(
      otpRequired: false,
      user: UserModel.fromApi(
        response['user'] as Map<String, dynamic>,
        avatarBase: ApiClient.origin,
      ),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/merchant/auth/logout');
    } on ApiException {
      // Token may already be invalid; local sign-out proceeds regardless.
    } finally {
      await _api.clearToken();
    }
  }

  @override
  Future<void> completeOnboarding(OnboardingData data) async {
    await _api.multipart(
      '/merchant/onboarding',
      fields: {
        'business_name': data.businessName.trim(),
        if (data.description.trim().isNotEmpty)
          'description': data.description.trim(),
        'category': data.category,
        for (var i = 0; i < data.subcategories.length; i++)
          'subcategories[$i]': data.subcategories[i],
        'contact_name': data.contactName.trim(),
        'phone': data.phone.trim(),
        'email': data.email.trim(),
        'address': data.address.trim(),
        'city': data.city.trim(),
        if (data.zip.trim().isNotEmpty) 'zip': data.zip.trim(),
      },
      files: {
        if (data.logoPath != null) 'logo': data.logoPath!,
        if (data.storefrontPath != null) 'storefront': data.storefrontPath!,
      },
    );
  }

  @override
  Future<OnboardingStatus> getOnboardingStatus() async {
    final response =
        await _api.get('/merchant/onboarding/status') as Map<String, dynamic>;
    return OnboardingStatus(
      submitted: (response['submitted'] as bool?) ?? false,
      status: response['status'] as String?,
      storeActive: (response['store_active'] as bool?) ?? false,
    );
  }
}
