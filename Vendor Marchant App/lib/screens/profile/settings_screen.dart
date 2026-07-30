import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              context.watch<AuthProvider>().user?.avatarUrl ??
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
            ),
          ),
        ),
        title: Text('Store Settings', style: AppTextStyles.brand),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Notifications', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ToggleRow(
                  title: 'New Orders',
                  subtitle: 'Get notified when a customer places an order',
                  value: store.notifyNewOrders,
                  onChanged: store.setNotifyNewOrders,
                ),
                const Divider(),
                _ToggleRow(
                  title: 'Payouts',
                  subtitle: 'Status updates on your earnings transfers',
                  value: store.notifyPayouts,
                  onChanged: store.setNotifyPayouts,
                ),
                const Divider(),
                _ToggleRow(
                  title: 'Customer Reviews',
                  subtitle: 'Alerts for new feedback and ratings',
                  value: store.notifyReviews,
                  onChanged: store.setNotifyReviews,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.settings_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('App Preferences',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(
                    store.language,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final lang = await showModalBottomSheet<String>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            'English (United States)',
                            'Spanish',
                            'French',
                            'Arabic',
                          ]
                              .map(
                                (l) => ListTile(
                                  title: Text(l),
                                  trailing: store.language == l
                                      ? const Icon(Icons.check,
                                          color: AppColors.primary)
                                      : null,
                                  onTap: () => Navigator.pop(context, l),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                    if (lang != null) store.setLanguage(lang);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Help Center (mock)'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text('Legal & Privacy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Legal & Privacy'),
                        content: const Text(
                          'HillGo Vendor Terms of Service and Privacy Policy (mock content for demo).',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: AppColors.errorSoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Logout?'),
                    content: const Text(
                      'You will need to sign in again to manage your store.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/login');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version 2.4.1 (HillGo-Production)',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyBold),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
    );
  }
}
