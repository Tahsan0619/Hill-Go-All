import '../../models/document_model.dart';
import '../../models/user_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);

  final ApiClient _api;

  @override
  Future<UserModel> getProfile() async =>
      UserModel.fromJson(await _api.get('/courier/me') as Map<String, dynamic>);

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async =>
      UserModel.fromJson(await _api.patch('/courier/me', body: data) as Map<String, dynamic>);

  @override
  Future<void> updateNotificationPrefs({required bool assignments, required bool payouts}) =>
      _api.patch('/courier/settings', body: {
        'notify_assignments': assignments,
        'notify_payouts': payouts,
      });

  @override
  Future<void> updateLanguage(String languageCode) =>
      _api.patch('/courier/settings', body: {'language': languageCode});

  @override
  Future<UserModel> updateVehicle({String? type, String? name, String? plate}) async {
    await _api.patch('/courier/vehicle', body: {
      if (type != null) 'vehicle_type': type,
      if (name != null) 'vehicle_name': name,
      if (plate != null) 'plate': plate,
    });
    return getProfile();
  }

  @override
  Future<List<CourierDocument>> getDocuments() async {
    final data = await _api.get('/courier/documents') as List<dynamic>;
    return data.map((row) => CourierDocument.fromJson(row as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> uploadDocument(String docKey, String filePath) =>
      _api.multipart('/courier/documents/$docKey/upload', filePath: filePath);

  @override
  Future<bool> setPresence(bool online) async {
    final data = await _api.patch('/courier/presence', body: {'online': online});
    return (data as Map<String, dynamic>)['online'] == true;
  }
}
