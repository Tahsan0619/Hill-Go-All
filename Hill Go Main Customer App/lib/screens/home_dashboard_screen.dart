import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../services/api/food_api.dart';
import '../services/api/notifications_api.dart';
import '../services/api/wallet_api.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/hills_tracking_background.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/service_category_icon.dart';

/// Home dashboard content only — no Scaffold/bottom nav, meant to be
/// embedded inside [MainShellScreen]'s IndexedStack.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    this.onSearchTap,
    this.onNotificationsTap,
    this.onCartTap,
    this.onRideTap,
    this.onFoodTap,
    this.onParcelTap,
    this.onMarketTap,
    this.onHotelTap,
    this.onRentalTap,
    this.onSosTap,
    this.onPromoTap,
    this.onSeeAllOffers,
    this.onWalletTap,
    this.onVouchersTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onRideTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onParcelTap;
  final VoidCallback? onMarketTap;
  final VoidCallback? onHotelTap;
  final VoidCallback? onRentalTap;
  final VoidCallback? onSosTap;
  final VoidCallback? onPromoTap;
  final VoidCallback? onSeeAllOffers;
  final VoidCallback? onWalletTap;
  final VoidCallback? onVouchersTap;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<RestaurantInfo> _restaurants = [];
  bool _restaurantsLoading = true;
  int _unreadNotifications = 0;
  int _activePromos = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Each section loads independently; failures leave that section empty.
    FoodApi.restaurants().then((rows) {
      if (!mounted) return;
      setState(() {
        _restaurants = rows;
        _restaurantsLoading = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _restaurantsLoading = false);
    });
    NotificationsApi.inbox().then((inbox) {
      if (!mounted) return;
      setState(() => _unreadNotifications = inbox.unread);
    }).catchError((_) {});
    WalletApi.promos().then((promos) {
      if (!mounted) return;
      setState(() => _activePromos = promos.length);
    }).catchError((_) {});
    AuthService.refreshUser().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {});
  }

  Future<void> _onRefresh() async {
    await _load();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.user;
    final unreadNotifications = _unreadNotifications;
    final textTheme = Theme.of(context).textTheme;
    final colors = HillGoColors.of(context);

    return SafeArea(
      bottom: false,
      child: AppPullRefresh(
        onRefresh: _onRefresh,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 112,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const HillsTrackingBackground(borderRadius: 0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: AppNetworkImage(
                              imageUrl: user.avatarUrl,
                              width: 44,
                              height: 44,
                              fallbackColor: AppColors.accentBlueSoft,
                              fallbackIcon: Icons.person,
                              fallbackIconSize: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HillGo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    color: colors.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name.isEmpty
                                      ? _greeting
                                      : '$_greeting, ${user.name.split(' ').first}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          CartIconButton(
                            onTap: widget.onCartTap ?? () {},
                            emphasized: true,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onNotificationsTap,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.surface.withValues(alpha: 0.94),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: colors.cardBorder),
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (unreadNotifications > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unreadNotifications > 9
                                            ? '9+'
                                            : '$unreadNotifications',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: widget.onSearchTap,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colors.textMuted),
                    const SizedBox(width: 12),
                    Text('Where to?', style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Ride',
                    icon: Icons.two_wheeler,
                    color: AppColors.primaryNavy,
                    onTap: widget.onRideTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Food',
                    icon: Icons.restaurant,
                    color: AppColors.accentOrange,
                    onTap: widget.onFoodTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Parcel',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.accentBlue,
                    onTap: widget.onParcelTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Market',
                    icon: Icons.storefront,
                    color: const Color(0xFF6FBE44),
                    onTap: widget.onMarketTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Hotel',
                    icon: Icons.hotel_outlined,
                    color: const Color(0xFF7C4DFF),
                    onTap: widget.onHotelTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'Rental',
                    icon: Icons.directions_car_filled_outlined,
                    color: const Color(0xFF00897B),
                    onTap: widget.onRentalTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'SOS',
                    icon: Icons.sos_outlined,
                    color: const Color(0xFFE53935),
                    onTap: widget.onSosTap,
                  ),
                ),
                Expanded(
                  child: ServiceCategoryIcon(
                    label: 'More',
                    icon: Icons.grid_view_rounded,
                    color: AppColors.navy,
                    onTap: widget.onSeeAllOffers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PromoBanner(onTap: widget.onPromoTap),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Restaurants Near You',
              trailingLabel: 'See all',
              onTrailingTap: widget.onFoodTap,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 210,
              child: _restaurantsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryNavy),
                    )
                  : _restaurants.isEmpty
                      ? Center(
                          child: Text(
                            'No restaurants available yet.',
                            style: textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _restaurants.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final item = _restaurants[index];
                            return GestureDetector(
                              onTap: widget.onFoodTap,
                              child: _OfferCard(item: item),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _QuickLinkCard(
                    title: 'Hill Wallet',
                    subtitle: '${user.walletBalance.toStringAsFixed(2)} BDT',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryNavy,
                    onTap: widget.onWalletTap,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickLinkCard(
                    title: 'My Vouchers',
                    subtitle: '$_activePromos active',
                    icon: Icons.confirmation_number_outlined,
                    color: AppColors.accentOrange,
                    onTap: widget.onVouchersTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.item});

  final RestaurantInfo item;

  @override
  Widget build(BuildContext context) {
    final colors = HillGoColors.of(context);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: item.imageUrl,
                width: 220,
                height: 100,
                fallbackColor: item.color,
                fallbackIcon: Icons.restaurant,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.freeDelivery)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandLime,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Free Delivery',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.cuisine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HillGoColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
