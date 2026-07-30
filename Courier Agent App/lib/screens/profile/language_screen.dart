import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../widgets/common_widgets.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    const languages = ['English (US)', 'Spanish', 'French'];
    return Scaffold(
      appBar: const HillGoAppBar(title: 'App Language', showBack: true, showBell: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: languages.map((language) {
                final selected = profile.language == language;
                return ListTile(
                  title: Text(language),
                  trailing: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                  onTap: () => profile.updateLanguage(language),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
