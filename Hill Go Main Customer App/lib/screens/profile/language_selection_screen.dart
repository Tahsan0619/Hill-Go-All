import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  static const String routeName = '/profile/language';

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selected = 'English';

  static const _languages = [
    ('English', 'English (US)'),
    ('Bangla', 'বাংলা'),
    ('Hindi', 'हिन्दी'),
    ('Arabic', 'العربية'),
  ];

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
                    final (name, native) = _languages[index];
                    final selected = name == _selected;
                    return Column(
                      children: [
                        RadioListTile<String>(
                          value: name,
                          groupValue: _selected,
                          onChanged: (value) => setState(() => _selected = value!),
                          activeColor: AppColors.primaryNavy,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            name,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(native, style: textTheme.bodyMedium),
                        ),
                        if (index != _languages.length - 1)
                          const Divider(height: 1, color: AppColors.cardBorder),
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
