import '../models/catalog_models.dart';
import 'api/api_client.dart';
import 'api/sos_api.dart';

/// SOS contacts and alerts backed by SosApi.
class SosService {
  SosService._();

  static List<EmergencyContact> _contacts = [];
  static List<SosAlertEntry> _alerts = [];
  static bool _loaded = false;

  static List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  static List<SosAlertEntry> get alerts => List.unmodifiable(_alerts);

  /// Loads contacts + recent alerts from the API. Safe to call repeatedly.
  static Future<void> refresh() async {
    final results = await Future.wait([
      SosApi.contacts(),
      SosApi.alerts(),
    ]);
    _contacts = results[0] as List<EmergencyContact>;
    _alerts = results[1] as List<SosAlertEntry>;
    _loaded = true;
  }

  static Future<void> ensureLoaded() async {
    if (!_loaded) await refresh();
  }

  static Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String relation = 'Contact',
  }) async {
    final contact = await SosApi.addContact(
      name: name,
      phone: phone,
      relation: relation,
    );
    _contacts = [..._contacts, contact];
    return contact;
  }

  static Future<void> removeContact(int id) async {
    await SosApi.deleteContact(id);
    _contacts = _contacts.where((c) => c.id != id).toList();
  }

  /// Triggers an SOS alert via the API and returns a confirmation message.
  static Future<String> triggerAlert({
    required String type,
    String locationLabel = 'Current location',
    double? lat,
    double? lng,
  }) async {
    final entry = await SosApi.trigger(
      type: type,
      locationLabel: locationLabel,
      lat: lat,
      lng: lng,
    );
    _alerts = [entry, ..._alerts];

    final names = _contacts.map((c) => c.name).join(', ');
    if (names.isEmpty) {
      return '${entry.type} sent. Share location: $locationLabel';
    }
    return '${entry.type} sent to $names · $locationLabel';
  }

  static void clearCache() {
    _contacts = [];
    _alerts = [];
    _loaded = false;
  }
}

/// Maps UI button labels to SosApi type codes.
String sosApiType(String uiLabel) {
  final lower = uiLabel.toLowerCase();
  if (lower.contains('police')) return 'police';
  if (lower.contains('ambulance')) return 'ambulance';
  if (lower.contains('location')) return 'location_share';
  if (lower.contains('ride')) return 'ride_sos';
  return 'sos';
}

/// Re-export for callers that catch API failures.
typedef SosApiException = ApiException;
