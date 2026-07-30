import 'package:flutter/material.dart';

import '../services/demo_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';
import '../widgets/hillgo_bottom_nav.dart';
import 'chatbot_screen.dart';
import 'food/restaurant_list_screen.dart';
import 'home_dashboard_screen.dart';
import 'hotel/hotel_bookings_screen.dart';
import 'hotel/hotel_list_screen.dart';
import 'login_screen.dart';
import 'loyalty/rewards_center_screen.dart';
import 'marketplace/product_categories_screen.dart';
import 'nearby_services_screen.dart';
import 'notifications_screen.dart';
import 'parcel/parcel_history_screen.dart';
import 'parcel/parcel_type_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/language_selection_screen.dart';
import 'profile/saved_addresses_screen.dart';
import 'profile/settings_screen.dart';
import 'recommended_screen.dart';
import 'rental/rental_history_screen.dart';
import 'rental/rental_list_screen.dart';
import 'ride/pickup_drop_screen.dart';
import 'ride/ride_history_screen.dart';
import 'search_screen.dart';
import 'service_categories_screen.dart';
import 'sos/sos_contacts_screen.dart';
import 'sos/sos_screen.dart';
import 'wallet/payment_method_screen.dart';
import 'wallet/wallet_screen.dart';

/// App shell hosting the 5 primary tabs behind a bottom navigation bar.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  static const String routeName = '/home';

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final colors = HillGoColors.of(context);
    final tabs = <Widget>[
      HomeDashboardScreen(
        onSearchTap: () =>
            Navigator.of(context).pushNamed(SearchScreen.routeName),
        onNotificationsTap: () async {
          await Navigator.of(context).pushNamed(NotificationsScreen.routeName);
          setState(() {});
        },
        onRideTap: () =>
            Navigator.of(context).pushNamed(PickupDropScreen.routeName),
        onFoodTap: () =>
            Navigator.of(context).pushNamed(RestaurantListScreen.routeName),
        onParcelTap: () =>
            Navigator.of(context).pushNamed(ParcelTypeScreen.routeName),
        onMarketTap: () => Navigator.of(context)
            .pushNamed(ProductCategoriesScreen.routeName),
        onHotelTap: () =>
            Navigator.of(context).pushNamed(HotelListScreen.routeName),
        onRentalTap: () =>
            Navigator.of(context).pushNamed(RentalListScreen.routeName),
        onSosTap: () => Navigator.of(context).pushNamed(SosScreen.routeName),
        onPromoTap: () =>
            Navigator.of(context).pushNamed(PickupDropScreen.routeName),
        onSeeAllOffers: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: colors.background,
                appBar: AppBar(
                  title: const Text('Categories'),
                  backgroundColor: colors.surface,
                  foregroundColor: AppColors.navy,
                  elevation: 0,
                ),
                body: ServiceCategoriesScreen(
                  onCategoryTap: (category) {
                    final label = category.label.toLowerCase();
                    if (label == 'food') {
                      Navigator.of(context)
                          .pushNamed(RestaurantListScreen.routeName);
                    } else if (label == 'marketplace') {
                      Navigator.of(context)
                          .pushNamed(ProductCategoriesScreen.routeName);
                    } else if (label == 'ride') {
                      Navigator.of(context)
                          .pushNamed(PickupDropScreen.routeName);
                    } else if (label == 'hotel') {
                      Navigator.of(context)
                          .pushNamed(HotelListScreen.routeName);
                    } else if (label == 'rental') {
                      Navigator.of(context)
                          .pushNamed(RentalListScreen.routeName);
                    } else if (label == 'sos') {
                      Navigator.of(context).pushNamed(SosScreen.routeName);
                    }
                  },
                  onParcelBannerTap: () => Navigator.of(context)
                      .pushNamed(ParcelTypeScreen.routeName),
                  onRedeemTap: () => Navigator.of(context)
                      .pushNamed(RewardsCenterScreen.routeName),
                ),
              ),
            ),
          );
        },
        onWalletTap: () =>
            Navigator.of(context).pushNamed(WalletScreen.routeName),
        onVouchersTap: () =>
            Navigator.of(context).pushNamed(RewardsCenterScreen.routeName),
      ),
      const NearbyServicesScreen(),
      const RecommendedScreen(),
      const ChatbotScreen(),
      const _ProfileTabContent(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(index: _currentIndex, children: tabs),
            ),
          ),
          HillGoBottomNav(
            currentIndex: _currentIndex,
            onTap: _goToTab,
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatefulWidget {
  const _ProfileTabContent();

  @override
  State<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<_ProfileTabContent> {
  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = DemoAuthService.user;
    final colors = HillGoColors.of(context);

    final menuItems = <_ProfileMenuData>[
      _ProfileMenuData(
        'Edit Profile',
        Icons.person_outline,
        EditProfileScreen.routeName,
      ),
      _ProfileMenuData(
        'Hill Wallet',
        Icons.account_balance_wallet_outlined,
        WalletScreen.routeName,
      ),
      _ProfileMenuData(
        'My Addresses',
        Icons.location_on_outlined,
        SavedAddressesScreen.routeName,
      ),
      _ProfileMenuData(
        'Ride History',
        Icons.receipt_long_outlined,
        RideHistoryScreen.routeName,
      ),
      _ProfileMenuData(
        'Parcels',
        Icons.inventory_2_outlined,
        ParcelHistoryScreen.routeName,
      ),
      _ProfileMenuData(
        'Hotel Bookings',
        Icons.hotel_outlined,
        HotelBookingsScreen.routeName,
      ),
      _ProfileMenuData(
        'My Rentals',
        Icons.directions_car_filled_outlined,
        RentalHistoryScreen.routeName,
      ),
      _ProfileMenuData(
        'SOS & Safety',
        Icons.sos_outlined,
        SosScreen.routeName,
      ),
      _ProfileMenuData(
        'Emergency Contacts',
        Icons.contacts_outlined,
        SosContactsScreen.routeName,
      ),
      _ProfileMenuData(
        'Payment Methods',
        Icons.credit_card_outlined,
        PaymentMethodScreen.routeName,
      ),
      _ProfileMenuData(
        'Rewards',
        Icons.card_giftcard_outlined,
        RewardsCenterScreen.routeName,
      ),
      _ProfileMenuData(
        'Language',
        Icons.language_outlined,
        LanguageSelectionScreen.routeName,
      ),
      _ProfileMenuData(
        'Settings',
        Icons.settings_outlined,
        SettingsScreen.routeName,
      ),
      const _ProfileMenuData(
        'Log Out',
        Icons.logout,
        null,
        isDestructive: true,
      ),
    ];

    return AppPullRefresh(
      onRefresh: _onRefresh,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: AppNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 64,
                  height: 64,
                  fallbackColor: AppColors.accentBlueSoft,
                  fallbackIcon: Icons.person,
                  fallbackIconSize: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(user.phoneDisplay, style: textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Wallet · ৳${user.walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...menuItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  if (item.routeName != null) {
                    Navigator.of(context).pushNamed(item.routeName!);
                  } else {
                    DemoAuthService.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        color: item.isDestructive
                            ? Colors.redAccent
                            : colors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: item.isDestructive
                                ? Colors.redAccent
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProfileMenuData {
  const _ProfileMenuData(
    this.label,
    this.icon,
    this.routeName, {
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final String? routeName;
  final bool isDestructive;
}
