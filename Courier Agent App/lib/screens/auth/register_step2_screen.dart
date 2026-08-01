import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});
  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _picker = ImagePicker();
  String? _license;
  String? _nid;
  String? _vehicle;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _license = auth.licensePath;
    _nid = auth.nidDocPath;
    _vehicle = auth.vehicleDocPath;
  }

  Future<void> _pick(void Function(String) save) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image != null && mounted) setState(() => save(image.path));
  }

  void _continue() {
    if (_license == null || _nid == null || _vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload all three required documents')),
      );
      return;
    }
    context.read<AuthProvider>().saveRegistrationDocs(
      license: _license,
      nidDoc: _nid,
      vehicleDoc: _vehicle,
    );
    context.push('/register/verification');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                'Step 2 of 4',
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              const _RegistrationSteps(active: 2),
              const SizedBox(height: AppSpacing.xxl),
              Text('Upload documents', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Clear photos help us verify your courier account faster.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              _DocumentCard(
                title: 'Driver License',
                subtitle: 'Front side of your valid license',
                path: _license,
                icon: Icons.badge_outlined,
                onPick: () => _pick((path) => _license = path),
              ),
              _DocumentCard(
                title: 'NID Scan',
                subtitle: 'National ID or identity document',
                path: _nid,
                icon: Icons.credit_card_outlined,
                onPick: () => _pick((path) => _nid = path),
              ),
              _DocumentCard(
                title: 'Vehicle Registration',
                subtitle: 'Current registration or ownership proof',
                path: _vehicle,
                icon: Icons.description_outlined,
                onPick: () => _pick((path) => _vehicle = path),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: 'Continue', onPressed: _continue),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.title,
    required this.subtitle,
    required this.path,
    required this.icon,
    required this.onPick,
  });
  final String title;
  final String subtitle;
  final String? path;
  final IconData icon;
  final VoidCallback onPick;
  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    onTap: onPick,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: path == null
                ? AppColors.primary.withValues(alpha: .08)
                : AppColors.successBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            path == null ? icon : Icons.check_circle_rounded,
            color: path == null ? AppColors.primary : AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 3),
              Text(
                path ?? subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: path == null ? AppColors.textMuted : AppColors.success,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onPick,
          child: Text(path == null ? 'Upload' : 'Replace'),
        ),
      ],
    ),
  );
}

class _RegistrationSteps extends StatelessWidget {
  const _RegistrationSteps({required this.active});
  final int active;
  @override
  Widget build(BuildContext context) {
    const labels = ['Basic Info', 'Documents', 'Credentials', 'Review'];
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step <= active ? AppColors.primary : AppColors.divider,
                ),
                child: Text(
                  '$step',
                  style: AppTextStyles.caption.copyWith(
                    color: step <= active
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: step == active
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
