import '../models/models.dart';

abstract class AuthRepository {
  Future<DriverUser?> getCurrentSession();
  Future<DriverUser> login({required String email, required String password});
  Future<void> requestOtp({required String emailOrPhone});
  Future<DriverUser> verifyOtp({required String emailOrPhone, required String code});
  Future<DriverUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> requestPasswordReset({required String phone});
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
  Future<void> logout();
  Future<void> updateProfile(DriverUser user);
  Future<void> saveVehicle(VehicleInfo vehicle);
  Future<void> submitPersonalInfo({
    required String legalName,
    required String homeAddress,
    required String districtId,
    required String dob,
    required String nid,
  });
  Future<List<DistrictOption>> getDistricts();
  Future<void> completeOnboarding();
  Future<void> setOnboardingStep(OnboardingStep step);
}
