import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  static const _faqs = [
    ('How do I start receiving deliveries?', 'Turn on Active Now from the dashboard. You will receive assigned parcels when you are in a live service area.'),
    ('What if I cannot deliver a parcel?', 'Open the parcel details, contact the recipient if appropriate, and contact support before marking any delivery as failed.'),
    ('How are my earnings calculated?', 'Your earnings include base pay, customer tips, and any eligible surge or incentive payments.'),
    ('How do I stay safe on delivery?', 'Follow local traffic laws, never use your phone while riding or driving, and report an unsafe pickup or drop-off location immediately.'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HillGoAppBar(title: 'Help & Safety', showBack: true, showBell: false),
    body: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
      Text('Help & Safety', style: AppTextStyles.h1),
      const SizedBox(height: 6), Text('Answers for common courier questions.', style: AppTextStyles.bodySecondary),
      const SizedBox(height: AppSpacing.lg),
      AppCard(padding: EdgeInsets.zero, child: Column(children: _faqs.map((faq) => ExpansionTile(
        title: Text(faq.$1, style: AppTextStyles.h3),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(faq.$2, style: AppTextStyles.bodySecondary)],
      )).toList())),
    ]),
  );
}
