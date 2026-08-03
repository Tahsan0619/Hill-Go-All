import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _kPush = 'hillgo_rider_settings_push';
  static const _kSound = 'hillgo_rider_settings_sound';
  static const _kAutoAcceptNav = 'hillgo_rider_settings_auto_accept_nav';
  static const _kNightMap = 'hillgo_rider_settings_night_map';

  bool _push = true;
  bool _sound = true;
  bool _autoAcceptNav = true;
  bool _nightModeMap = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _push = prefs.getBool(_kPush) ?? true;
      _sound = prefs.getBool(_kSound) ?? true;
      _autoAcceptNav = prefs.getBool(_kAutoAcceptNav) ?? true;
      _nightModeMap = prefs.getBool(_kNightMap) ?? false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
                  onChanged: (v) {
                    setState(() => _push = v);
                    _setBool(_kPush, v);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Offer sound'),
                  value: _sound,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _sound = v);
                    _setBool(_kSound, v);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-open navigation'),
                  value: _autoAcceptNav,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _autoAcceptNav = v);
                    _setBool(_kAutoAcceptNav, v);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Night map style'),
                  value: _nightModeMap,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _nightModeMap = v);
                    _setBool(_kNightMap, v);
                  },
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
