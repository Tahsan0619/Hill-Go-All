import 'package:flutter/material.dart';

import '../../services/api/api_client.dart';
import '../../services/api/profile_api.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  static const String routeName = '/profile/language';

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selected;
  bool _saving = false;

  static const _languages = [
    ('en', 'English', 'English (US)'),
    ('bn', 'Bangla', 'বাংলা'),
    ('hi', 'Hindi', 'हिन्दी'),
    ('ar', 'Arabic', 'العربية'),
  ];

  @override
  void initState() {
    super.initState();
    final code = AuthService.user.language;
    _selected = _languages.any((l) => l.$1 == code) ? code : 'en';
  }

  Future<void> _select(String code) async {
    if (_saving || code == _selected) return;
    setState(() {
      _selected = code;
      _saving = true;
    });
    try {
      await ProfileApi.setLanguage(code);
      await AuthService.refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Language updated'),
          duration: Duration(seconds: 1),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(title: 'Language'),
              const SizedBox(height: 20),
              Text(
                'Choose your preferred language',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: List.generate(_languages.length, (index) {
                    final (code, name, native) = _languages[index];
                    final selected = code == _selected;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: _saving ? null : () => _select(code),
                          title: Text(
                            name,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(native, style: textTheme.bodyMedium),
                          trailing: Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.textMuted,
                          ),
                        ),
                        if (index != _languages.length - 1)
                          const Divider(
                              height: 1, color: AppColors.cardBorder),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
