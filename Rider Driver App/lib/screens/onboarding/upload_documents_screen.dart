import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import 'onboarding_shell.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  static const int _maxBytes = 5 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().load();
    });
  }

  Future<XFile?> _pickConstrainedImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return null;
    if (file.path.isNotEmpty) {
      final length = await File(file.path).length();
      if (length > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image must be 5 MB or smaller')),
          );
        }
        return null;
      }
    }
    return file;
  }

  Future<void> _pickAndUploadLicense(DocumentItem doc) async {
    final file = await _pickConstrainedImage();
    if (file == null || !mounted) return;
    final ok = await context.read<DocumentProvider>().upload(doc.id, file.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'License uploaded' : 'Upload failed')),
    );
  }

  Future<void> _pickAndUploadGeneric(DocumentItem doc) async {
    final file = await _pickConstrainedImage();
    if (file == null || !mounted) return;
    final ok = await context.read<DocumentProvider>().upload(doc.id, file.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '${doc.title} uploaded' : 'Upload failed')),
    );
  }

  Future<void> _submitTokenFlow(DocumentItem doc) async {
    final tokenCtrl = TextEditingController(text: doc.tokenNumber ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload with Token Number', style: AppTextStyles.title),
                const SizedBox(height: 8),
                Text(
                  'No driving license? Enter your token number and upload a clear photo of the token paper as evidence.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Token number',
                  controller: tokenCtrl,
                  hint: 'e.g. TKN-4821-DHK',
                  validator: (v) {
                    if (v == null || v.trim().length < 4) {
                      return 'Enter a valid token number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Next: Upload token photo',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx, true);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      tokenCtrl.dispose();
      return;
    }

    final file = await _pickConstrainedImage();
    if (file == null || !mounted) {
      tokenCtrl.dispose();
      return;
    }

    final ok = await context.read<DocumentProvider>().submitToken(
      id: doc.id,
      tokenNumber: tokenCtrl.text.trim(),
      path: file.path,
    );
    tokenCtrl.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Token evidence submitted for review'
              : (context.read<DocumentProvider>().error ?? 'Submit failed'),
        ),
      ),
    );
  }

  void _openIdProofOptions(DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID verification', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              doc.description ??
                  'Upload a driving license, or use your token number if you do not have a license.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.cardBlueTint,
                child: Icon(Icons.badge_outlined, color: AppColors.primary),
              ),
              title: Text('I have a driving license', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              subtitle: const Text('Upload license photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadLicense(doc);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF4E8),
                child: Icon(Icons.confirmation_number_outlined, color: AppColors.orange),
              ),
              title: Text('I use a token number', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              subtitle: const Text('Enter token + upload token photo'),
              onTap: () {
                Navigator.pop(ctx);
                _submitTokenFlow(doc);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _viewOrUpload(DocumentItem doc) {
    if (doc.status == DocStatus.verified || doc.status == DocStatus.uploaded) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(doc.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.subtitle ?? 'Document on file'),
              if (doc.tokenNumber != null) ...[
                const SizedBox(height: 8),
                Text('Token: ${doc.tokenNumber}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            if (doc.allowsTokenAlternative)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openIdProofOptions(doc);
                },
                child: const Text('Replace'),
              ),
          ],
        ),
      );
      return;
    }

    if (doc.status == DocStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete previous documents first')),
      );
      return;
    }

    if (doc.allowsTokenAlternative) {
      _openIdProofOptions(doc);
    } else {
      _pickAndUploadGeneric(doc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentProvider>();
    final fromAccount = GoRouterState.of(context).uri.queryParameters['from'] == 'account';

    return OnboardingShell(
      title: 'Partner Portal',
      currentTab: 1,
      stepLabel: 'Documents',
      child: docs.isLoading && docs.documents.isEmpty
          ? const LoadingView()
          : docs.error != null && docs.documents.isEmpty
              ? ErrorView(message: docs.error!, onRetry: () => docs.load())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Text('Upload Documents', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    Text(
                      'Riders without a driving license can submit a token number with photo evidence.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'License optional: use Token Number + token photo if you do not have a license.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.orangeDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProgressCard(progress: docs.progress),
                    const SizedBox(height: 16),
                    ...docs.documents.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DocCard(doc: d, onAction: () => _viewOrUpload(d)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: fromAccount ? 'Done' : 'Submit for Verification',
                      loading: context.watch<AuthProvider>().isLoading,
                      onPressed: () async {
                        if (fromAccount) {
                          context.go('/account');
                          return;
                        }
                        final auth = context.read<AuthProvider>();
                        final ok = await auth.finishOnboarding();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go('/onboarding/status');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(auth.error ?? 'Could not submit for review'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification Progress', style: AppTextStyles.body.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$pct%', style: AppTextStyles.moneyMd.copyWith(color: Colors.white, fontSize: 32)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Complete', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.05, 1),
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc, required this.onAction});
  final DocumentItem doc;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isVerified = doc.status == DocStatus.verified;
    final isUploaded = doc.status == DocStatus.uploaded;
    final isAction = doc.status == DocStatus.actionRequired;
    final isPending = doc.status == DocStatus.pending;

    Color iconBg = const Color(0xFFE8F8EE);
    Color accent = AppColors.success;
    if (isAction) {
      iconBg = const Color(0xFFFFE8D9);
      accent = AppColors.orangeAction;
    } else if (isPending) {
      iconBg = const Color(0xFFEEF0F3);
      accent = AppColors.textMuted;
    } else if (isUploaded) {
      iconBg = AppColors.cardBlueTint;
      accent = AppColors.primary;
    }

    return SectionCard(
      leftAccent: isAction ? AppColors.orangeAction : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              doc.allowsTokenAlternative
                  ? Icons.badge_outlined
                  : Icons.description_outlined,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  doc.subtitle ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: isVerified || isUploaded
                        ? AppColors.success
                        : isAction
                            ? AppColors.orangeAction
                            : AppColors.textSecondary,
                  ),
                ),
                if (doc.tokenNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Token: ${doc.tokenNumber}',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (doc.allowsTokenAlternative && isAction) ...[
                  const SizedBox(height: 4),
                  Text(
                    'License or Token accepted',
                    style: AppTextStyles.caption.copyWith(color: AppColors.orangeDark),
                  ),
                ],
                const SizedBox(height: 10),
                if (isVerified || isUploaded)
                  OutlinedButton(onPressed: onAction, child: const Text('View'))
                else if (isAction)
                  ElevatedButton.icon(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeAction,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    icon: Icon(
                      doc.allowsTokenAlternative ? Icons.upload_file : Icons.upload_file,
                      size: 18,
                    ),
                    label: Text(doc.allowsTokenAlternative ? 'Upload License / Token' : 'Upload PDF/JPG'),
                  )
                else
                  const Icon(Icons.schedule, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
