import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class RegisterStep4Screen extends StatelessWidget {
  const RegisterStep4Screen({super.key});

  Future<void> _submit(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.completeRegistration();
    if (!context.mounted) return;
    if (success) {
      if (auth.registrationNotice != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.registrationNotice!)),
        );
      }
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Could not submit registration')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Courier', style: AppTextStyles.brand),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 4 of 4',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _ReviewSteps(),
                const SizedBox(height: AppSpacing.xxl),
                Text('Review & submit', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Check your details before creating your courier account.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xl),
                _ReviewCard(
                  title: 'Basic information',
                  editRoute: '/register',
                  rows: [
                    _ReviewRow('Full name', auth.regFullName),
                    _ReviewRow('Contact number', auth.regPhone),
                    _ReviewRow('NID / Identity', auth.regNid),
                    _ReviewRow('Vehicle', auth.regVehicleType),
                  ],
                ),
                _ReviewCard(
                  title: 'Documents',
                  editRoute: '/register/documents',
                  rows: [
                    _ReviewRow('Driver License', _filename(auth.licensePath)),
                    _ReviewRow('NID Scan', _filename(auth.nidDocPath)),
                    _ReviewRow(
                      'Vehicle Registration',
                      _filename(auth.vehicleDocPath),
                    ),
                  ],
                ),
                _ReviewCard(
                  title: 'Account credentials',
                  editRoute: '/register/verification',
                  rows: [
                    _ReviewRow('Email', auth.regEmail),
                    const _ReviewRow('Password', '••••••••'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  color: AppColors.accentSoft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Your application will be reviewed so you can start delivering safely.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Submit application',
                  loading: auth.isLoading,
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _filename(String? path) {
    if (path == null || path.isEmpty) return 'Not uploaded';
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.last;
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.editRoute,
    required this.rows,
  });
  final String title;
  final String editRoute;
  final List<_ReviewRow> rows;
  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.h3)),
            TextButton(
              onPressed: () => context.push(editRoute),
              child: const Text('Edit'),
            ),
          ],
        ),
        const Divider(),
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(row.label, style: AppTextStyles.bodySecondary),
                ),
                Flexible(
                  child: Text(
                    row.value,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;
}

class _ReviewSteps extends StatelessWidget {
  const _ReviewSteps();
  @override
  Widget build(BuildContext context) {
    const labels = ['Basic Info', 'Documents', 'Credentials', 'Review'];
    return Row(
      children: List.generate(
        4,
        (i) => Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: i == 3 ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
