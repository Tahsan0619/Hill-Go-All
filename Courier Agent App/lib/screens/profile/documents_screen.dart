import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HillGoAppBar(title: 'Document Status', showBack: true, showBell: false),
    body: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
      Text('Your verified documents keep your courier account active.', style: AppTextStyles.bodySecondary),
      const SizedBox(height: AppSpacing.lg),
      ...const [
        ('Driver license', 'Verified · Expires Jun 2028', Icons.badge_outlined),
        ('Vehicle registration', 'Verified · Expires Mar 2027', Icons.directions_car_outlined),
        ('Identity document', 'Verified · Reviewed Jan 2026', Icons.person_outline),
      ].map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.successBg, child: Icon(item.$3, color: AppColors.success)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$1, style: AppTextStyles.h3), Text(item.$2, style: AppTextStyles.caption)])),
          const StatusChip(label: 'VERIFIED', fg: AppColors.success, bg: AppColors.successBg),
        ])),
      )),
    ]),
  );
}
