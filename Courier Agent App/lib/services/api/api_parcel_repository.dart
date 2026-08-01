import '../../models/parcel_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiParcelRepository implements ParcelRepository {
  ApiParcelRepository(this._api);

  final ApiClient _api;

  // App filter labels → backend `period` query values.
  static const _periods = {'daily': 'today', 'weekly': 'week', 'monthly': 'month'};

  @override
  Future<List<ParcelModel>> getAssignedParcels() async {
    final data = await _api.get('/courier/parcels/assigned', query: {
      'per_page': '50',
    }) as List<dynamic>;
    return data.map((row) => ParcelModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  @override
  Future<ParcelHistoryPage> getParcelHistory({
    String? query,
    String period = 'daily',
    int page = 1,
  }) async {
    final data = await _api.get('/courier/parcels/history', query: {
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (_periods.containsKey(period)) 'period': _periods[period]!,
      'page': '$page',
      'per_page': '50',
    }) as Map<String, dynamic>;
    return ParcelHistoryPage(
      items: (data['data'] as List<dynamic>? ?? const [])
          .map((row) => ParcelModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
      totalEarnings: _optionalDouble(data['total_earnings'] ?? data['payout_total']),
    );
  }

  static double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  @override
  Future<ParcelModel> getParcelById(String id) async =>
      ParcelModel.fromJson(await _api.get('/courier/parcels/$id') as Map<String, dynamic>);

  @override
  Future<ParcelModel> confirmPickupOtp(String parcelId, String otp) async => ParcelModel.fromJson(
    await _api.post('/courier/parcels/$parcelId/pickup-otp', body: {'otp': otp}) as Map<String, dynamic>,
  );

  @override
  Future<ParcelModel> startTransit(String parcelId) async => ParcelModel.fromJson(
    await _api.post('/courier/parcels/$parcelId/start-transit') as Map<String, dynamic>,
  );

  @override
  Future<ParcelModel> confirmDeliveryOtp(String parcelId, String otp) async => ParcelModel.fromJson(
    await _api.post('/courier/parcels/$parcelId/delivery-otp', body: {'otp': otp}) as Map<String, dynamic>,
  );

  @override
  Future<ParcelModel> markFailed(String parcelId, String reason) async => ParcelModel.fromJson(
    await _api.post('/courier/parcels/$parcelId/fail', body: {'reason': reason}) as Map<String, dynamic>,
  );

  @override
  Future<void> uploadProof(String parcelId, {required String type, required String filePath}) =>
      _api.multipart('/courier/parcels/$parcelId/proof', filePath: filePath, fields: {'type': type});
}
