import 'package:flutter/material.dart';

import '../../services/demo_auth_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/settings_tile.dart';
import '../loyalty/rewards_center_screen.dart';
import '../wallet/payment_method_screen.dart';
import 'language_selection_screen.dart';
import 'saved_addresses_screen.dart';
import '../login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/profile/settings';

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _confirmLogout(BuildContext context) {
    final colors = HillGoColors.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log out',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of HillGo?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              DemoAuthService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = DemoAuthService.user;
    final theme = ThemeService.instance;

    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        final colors = HillGoColors.of(context);
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppBackBar(title: 'Settings'),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            user.initials,
                            style: textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.phoneDisplay,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            SettingsTile(
                              icon: Icons.dark_mode_outlined,
                              label: 'Dark Mode',
                              trailing: Switch.adaptive(
                                value: theme.isDark,
                                onChanged: theme.setDark,
                              ),
                            ),
                            SettingsTile(
                              icon: Icons.location_on_outlined,
                              label: 'Saved Addresses',
                              onTap: () =>
                                  _push(context, const SavedAddressesScreen()),
                            ),
                            SettingsTile(
                              icon: Icons.language_outlined,
                              label: 'Language',
                              trailingText: 'English',
                              onTap: () => _push(
                                context,
                                const LanguageSelectionScreen(),
                              ),
                            ),
                            SettingsTile(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Payment Methods',
                              onTap: () =>
                                  _push(context, const PaymentMethodScreen()),
                            ),
                            SettingsTile(
                              icon: Icons.card_giftcard_outlined,
                              label: 'Rewards',
                              iconColor: AppColors.accentOrange,
                              iconBackground: AppColors.accentOrangeSoft,
                              onTap: () =>
                                  _push(context, const RewardsCenterScreen()),
                            ),
                            SettingsTile(
                              icon: Icons.help_outline,
                              label: 'Help',
                              onTap: () =>
                                  _snack(context, 'Help center coming soon'),
                            ),
                            SettingsTile(
                              icon: Icons.logout,
                              label: 'Logout',
                              iconColor: Colors.redAccent,
                              iconBackground: const Color(0xFFFDECEC),
                              showDivider: false,
                              onTap: () => _confirmLogout(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
