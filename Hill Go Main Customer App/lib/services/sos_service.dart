import '../data/dummy_data.dart';

/// In-memory SOS helpers: emergency contacts and recent alerts.
class SosService {
  SosService._();

  static final List<EmergencyContact> _contacts =
      List<EmergencyContact>.from(dummyEmergencyContacts);

  static final List<SosAlertEntry> _alerts =
      List<SosAlertEntry>.from(dummySosHistory);

  static List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  static List<SosAlertEntry> get alerts => List.unmodifiable(_alerts);

  static void addContact(EmergencyContact contact) {
    _contacts.add(contact);
  }

  static void removeContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
  }

  /// Records a demo SOS alert and returns a confirmation message.
  static String triggerAlert({
    required String type,
    String locationLabel = 'Current location · Gulshan, Dhaka',
  }) {
    final entry = SosAlertEntry(
      id: 'sos${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      timeLabel: 'Just now',
      status: 'Active',
    );
    _alerts.insert(0, entry);

    final names = _contacts.map((c) => c.name).join(', ');
    if (names.isEmpty) {
      return '$type sent. Share location: $locationLabel';
    }
    return '$type sent to $names · $locationLabel';
  }
}
