import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          SectionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : 'H').toUpperCase(),
                    style: AppTextStyles.headline.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Partner', style: AppTextStyles.title),
                      Text(user?.email ?? '', style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 4),
                      Text(
                        '★ ${(user?.rating ?? 0).toStringAsFixed(2)} • HillGo Rider',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Tile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () => context.push('/account/edit'),
          ),
          _Tile(
            icon: Icons.directions_car_outlined,
            title: 'Vehicle Information',
            subtitle: user?.vehicle?.displayName ?? 'Add your vehicle',
            onTap: () => context.push('/account/vehicle'),
          ),
          _Tile(
            icon: Icons.folder_outlined,
            title: 'Documents',
            subtitle: 'License or Token number',
            onTap: () => context.push('/onboarding/documents?from=account'),
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.push('/account/settings'),
          ),
          _Tile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reach us at support@hillgo.com or 09678-445566'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout, color: AppColors.tips),
            label: Text('Log out', style: AppTextStyles.button.copyWith(color: AppColors.tips)),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          subtitle: subtitle == null ? null : Text(subtitle!, style: AppTextStyles.caption),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
