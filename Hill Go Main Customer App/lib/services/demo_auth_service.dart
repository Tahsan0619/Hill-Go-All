import '../data/app_images.dart';
import '../data/dummy_data.dart';

/// Demo account for testing the full HillGo customer app without a backend.
class DemoUser {
  const DemoUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.phoneDisplay,
    required this.walletBalance,
    required this.loyaltyPoints,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final String phone;
  final String phoneDisplay;
  final double walletBalance;
  final int loyaltyPoints;
  final String avatarUrl;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  DemoUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? phoneDisplay,
    double? walletBalance,
    int? loyaltyPoints,
    String? avatarUrl,
  }) {
    return DemoUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneDisplay: phoneDisplay ?? this.phoneDisplay,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static const preset = DemoUser(
    name: 'Alex Morgan',
    email: 'demo@hillgo.com',
    phone: '01712345678',
    phoneDisplay: '+880 1712-345678',
    walletBalance: 1240.50,
    loyaltyPoints: 1240,
    avatarUrl: AppImages.avatar,
  );
}

/// Handles demo login, session, and seeded test data.
class DemoAuthService {
  DemoAuthService._();

  // ── Demo credentials (share with testers) ──────────────────────────────
  static const String demoEmail = 'demo@hillgo.com';
  static const String demoPassword = 'demo1234';
  static const String demoPhone = '01712345678';
  static const String demoPhoneDisplay = '+880 1712-345678';
  static const String demoOtp = '123456';

  static DemoUser? _currentUser;
  static String? _pendingPhone;

  static bool get isLoggedIn => _currentUser != null;
  static DemoUser get user => _currentUser ?? DemoUser.preset;
  static String? get pendingPhone => _pendingPhone;

  static String credentialSummary() =>
      'Email: $demoEmail · Password: $demoPassword · Phone: $demoPhone · OTP: $demoOtp';

  static String _normalizePhone(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static bool isDemoPhone(String phone) {
    final normalized = _normalizePhone(phone);
    return normalized == demoPhone ||
        normalized.endsWith('1712345678') ||
        normalized == '8801712345678';
  }

  static void startPhoneLogin(String phone) {
    _pendingPhone = isDemoPhone(phone) ? demoPhoneDisplay : phone;
  }

  static bool verifyOtp(String otp) {
    if (otp.trim() != demoOtp) return false;
    return login();
  }

  static bool loginWithEmail(String email, String password) {
    final ok = email.trim().toLowerCase() == demoEmail &&
        password == demoPassword;
    if (ok) login();
    return ok;
  }

  static bool login() {
    _currentUser = DemoUser.preset;
    _pendingPhone = null;
    _seedDemoData();
    return true;
  }

  static void logout() {
    _currentUser = null;
    _pendingPhone = null;
    FoodCartStore.clear();
    MarketplaceCartStore.clear();
  }

  static void updateProfile({String? name, String? email, String? phone}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      phoneDisplay: phone ?? _currentUser!.phoneDisplay,
    );
  }

  static void _seedDemoData() {
    FoodCartStore.clear();
    final restaurant = dummyRestaurants.first;
    final item = restaurant.menu.first.items.first;
    FoodCartStore.add(item, restaurant.name, quantity: 1);

    MarketplaceCartStore.clear();
    MarketplaceCartStore.add(dummyProducts[0]);
    MarketplaceCartStore.add(dummyProducts[2], quantity: 1);
  }
}

/// In-memory marketplace cart (mirrors [FoodCartStore]).
class MarketplaceCartStore {
  MarketplaceCartStore._();

  static final List<CartLine> _lines = [];

  static List<CartLine> get lines => List.unmodifiable(_lines);

  static bool get isEmpty => _lines.isEmpty;

  static void add(Product product, {int quantity = 1}) {
    final index = _lines.indexWhere((l) => l.product.id == product.id);
    if (index != -1) {
      _lines[index].quantity += quantity;
    } else {
      _lines.add(CartLine(product: product, quantity: quantity));
    }
  }

  static void removeAt(int index) {
    if (index >= 0 && index < _lines.length) _lines.removeAt(index);
  }

  static void clear() => _lines.clear();

  static double get subtotal =>
      _lines.fold(0, (sum, line) => sum + line.lineTotal);
}
