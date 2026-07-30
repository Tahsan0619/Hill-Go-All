import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../models/parcel_model.dart';
import '../repositories.dart';
import 'mock_data.dart';

class MockParcelRepository implements ParcelRepository {
  final _rand = Random();
  final List<ParcelModel> _assigned = List.of(MockData.assignedParcels);
  final List<ParcelModel> _history = List.of(MockData.historyParcels);

  Future<void> _delay() async {
    await Future<void>.delayed(Duration(milliseconds: 300 + _rand.nextInt(900)));
  }

  @override
  Future<List<ParcelModel>> getAssignedParcels() async {
    await _delay();
    return List.unmodifiable(
      _assigned.where(
        (p) =>
            p.status == ParcelStatus.assigned ||
            p.status == ParcelStatus.pickedUp ||
            p.status == ParcelStatus.inTransit,
      ),
    );
  }

  @override
  Future<List<ParcelModel>> getParcelHistory({String? query, String period = 'daily'}) async {
    await _delay();
    var list = List<ParcelModel>.from(_history);
    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.orderId.toLowerCase().contains(q) ||
                (p.customerName?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    // Period filters reshape the summary totals in the provider; keep full list for demo UX.
    return list;
  }

  @override
  Future<ParcelModel> getParcelById(String id) async {
    await _delay();
    final all = [..._assigned, ..._history];
    return all.firstWhere(
      (p) => p.id == id || p.orderId == id,
      orElse: () => throw Exception('Parcel not found'),
    );
  }

  @override
  Future<void> confirmPickupOtp(String parcelId, String otp) async {
    await _delay();
    _validateOtp(otp, digits: 4);
    final idx = _assigned.indexWhere((p) => p.id == parcelId || p.orderId == parcelId);
    if (idx < 0) throw Exception('Parcel not found');
    _assigned[idx] = _assigned[idx].copyWith(status: ParcelStatus.pickedUp);
  }

  @override
  Future<void> confirmDeliveryOtp(String parcelId, String otp) async {
    await _delay();
    _validateOtp(otp, digits: 4);
    final idx = _assigned.indexWhere((p) => p.id == parcelId || p.orderId == parcelId);
    if (idx < 0) throw Exception('Parcel not found');
    final done = _assigned[idx].copyWith(
      status: ParcelStatus.delivered,
      completedAt: DateTime.now(),
      payout: _assigned[idx].estimatedEarnings + _assigned[idx].surgeBonus,
    );
    _assigned.removeAt(idx);
    _history.insert(0, done);
  }

  @override
  Future<void> markFailed(String parcelId, String reason) async {
    await _delay();
    final idx = _assigned.indexWhere((p) => p.id == parcelId || p.orderId == parcelId);
    if (idx < 0) throw Exception('Parcel not found');
    final failed = _assigned[idx].copyWith(
      status: ParcelStatus.failed,
      completedAt: DateTime.now(),
      payout: 0,
    );
    _assigned.removeAt(idx);
    _history.insert(0, failed);
  }

  Future<List<ParcelModel>> loadMoreHistory() async {
    await _delay();
    final start = _history.length;
    final extra = List.generate(3, (i) {
      final n = start + i + 1;
      return ParcelModel(
        id: 'h-extra-$n',
        orderId: 'HG-${8900 - n}',
        type: 'General',
        priority: ParcelPriority.standard,
        status: ParcelStatus.delivered,
        senderName: 'Warehouse $n',
        senderAddress: '$n Industrial Rd',
        senderPhone: '+1 (555) 000-${1000 + n}',
        receiverName: 'Customer $n',
        receiverAddress: '$n Main St',
        receiverPhone: '+1 (555) 111-${1000 + n}',
        pickup: const LatLng(40.75, -73.98),
        dropoff: const LatLng(40.74, -73.99),
        weightKg: 1.0 + i,
        estimatedEarnings: 8.0 + i * 2,
        surgeBonus: 0,
        distanceKm: 2.0 + i,
        etaMinutes: 10 + i,
        notes: '',
        createdAt: DateTime.now().subtract(Duration(days: n)),
        completedAt: DateTime.now().subtract(Duration(days: n - 1)),
        customerName: 'Customer $n',
        payout: 8.0 + i * 2,
      );
    });
    _history.addAll(extra);
    return List.from(_history);
  }

  void _validateOtp(String otp, {required int digits}) {
    final code = otp.trim();
    final demo = digits == 4 ? '1234' : '123456';
    final ok = code == demo || (code.length == digits && RegExp('\\d{$digits}').hasMatch(code));
    if (!ok) throw Exception('Invalid OTP. Use $demo or any $digits-digit code.');
  }
}
