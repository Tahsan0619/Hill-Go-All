import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class StoreHubScreen extends StatefulWidget {
  const StoreHubScreen({super.key});

  @override
  State<StoreHubScreen> createState() => _StoreHubScreenState();
}

class _StoreHubScreenState extends State<StoreHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<StoreProvider>();
      if (s.store == null) s.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().store;

    return Scaffold(
      appBar: const HillGoAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Store', style: AppTextStyles.h1),
          Text(
            'Manage your profile, branding, revenue, and reviews.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 16),
          if (store != null)
            AppCard(
              child: Row(
                children: [
                  NetworkThumb(
                    url: store.bannerUrl ?? '',
                    size: 56,
                    radius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: AppTextStyles.h3),
                        Text(
                          store.acceptingOrders
                              ? 'Accepting orders'
                              : 'Orders paused',
                          style: AppTextStyles.caption.copyWith(
                            color: store.acceptingOrders
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    store.isOpen ? Icons.store : Icons.store_mall_directory,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _HubTile(
            icon: Icons.storefront_outlined,
            color: AppColors.primary,
            title: 'Store Information',
            subtitle: 'Profile, hours, location & order status',
            onTap: () => context.push('/store/info'),
          ),
          _HubTile(
            icon: Icons.image_outlined,
            color: AppColors.accent,
            title: 'Store Branding',
            subtitle: 'Banner, logo, specialties & live preview',
            onTap: () => context.push('/store/branding'),
          ),
          _HubTile(
            icon: Icons.payments_outlined,
            color: const Color(0xFF1565C0),
            title: 'Revenue Dashboard',
            subtitle: 'Sales trends, transactions & payouts',
            onTap: () => context.push('/store/revenue'),
          ),
          _HubTile(
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFF00897B),
            title: 'Payout History',
            subtitle: 'Withdrawals and transfer status',
            onTap: () => context.push('/store/payouts'),
          ),
          _HubTile(
            icon: Icons.star_outline,
            color: AppColors.rating,
            title: 'Customer Reviews',
            subtitle: 'Ratings, replies & feedback',
            onTap: () => context.push('/store/reviews'),
          ),
          _HubTile(
            icon: Icons.settings_outlined,
            color: AppColors.textSecondary,
            title: 'Settings',
            subtitle: 'Notifications, language & logout',
            onTap: () => context.push('/store/settings'),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyBold),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
