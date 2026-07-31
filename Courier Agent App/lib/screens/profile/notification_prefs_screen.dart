import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: const HillGoAppBar(title: 'Notification Preferences', showBack: true, showBell: false),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        Text('Choose how HillGo keeps you updated.', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.lg),
        AppCard(padding: EdgeInsets.zero, child: Column(children: [
          SwitchListTile(
            value: profile.assignmentAlerts,
            onChanged: (value) => profile.updateNotificationPrefs(assignments: value, payouts: profile.payoutAlerts),
            title: const Text('Parcel assignment alerts'), subtitle: const Text('New parcel and delivery updates'),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: profile.payoutAlerts,
            onChanged: (value) => profile.updateNotificationPrefs(assignments: profile.assignmentAlerts, payouts: value),
            title: const Text('Payout alerts'), subtitle: const Text('Withdrawal and earnings updates'),
          ),
        ])),
      ]),
    );
  }
}
