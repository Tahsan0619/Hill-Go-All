import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _sound = true;
  bool _autoAcceptNav = true;
  bool _nightModeMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text('Preferences', style: AppTextStyles.titleBlue),
          const SizedBox(height: 8),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Trip offer alerts'),
                  value: _push,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _push = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Offer sound'),
                  value: _sound,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _sound = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-open navigation'),
                  value: _autoAcceptNav,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _autoAcceptNav = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Night map style'),
                  value: _nightModeMap,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _nightModeMap = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Account', style: AppTextStyles.titleBlue),
          const SizedBox(height: 8),
          SectionCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.tips),
              title: Text('Clear local session', style: AppTextStyles.body.copyWith(color: AppColors.tips)),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('HillGo Rider v1.0.0', style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
