import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/document_model.dart';
import '../../providers/profile_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadDocuments();
    });
  }

  Future<void> _upload(CourierDocument doc) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    final provider = context.read<ProfileProvider>();
    final ok = await provider.uploadDocument(doc.key, image.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '${doc.title} uploaded — pending review.'
            : (provider.error ?? 'Upload failed. Please try again.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HillGoAppBar(title: 'Document Status', showBack: true, showBell: false),
    body: Consumer<ProfileProvider>(builder: (context, provider, _) {
      if (provider.loading) return const LoadingView(message: 'Loading documents...');
      if (provider.documents.isEmpty) {
        return ErrorView(
          message: provider.error ?? 'Could not load your documents.',
          onRetry: provider.loadDocuments,
        );
      }
      return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        Text('Your verified documents keep your courier account active.', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.lg),
        ...provider.documents.map((doc) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(child: Row(children: [
            CircleAvatar(
              backgroundColor: _color(doc.status).withValues(alpha: .12),
              child: Icon(_icon(doc.key), color: _color(doc.status)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.title, style: AppTextStyles.h3),
              Text(_subtitle(doc), style: AppTextStyles.caption),
            ])),
            if (doc.status == 'verified')
              const StatusChip(label: 'VERIFIED', fg: AppColors.success, bg: AppColors.successBg)
            else
              TextButton(
                onPressed: () => _upload(doc),
                child: Text(doc.uploaded ? 'Replace' : 'Upload'),
              ),
          ])),
        )),
      ]);
    }),
  );

  String _subtitle(CourierDocument doc) {
    final expiry = doc.expiresAt == null ? '' : ' · Expires ${DateFormat('MMM yyyy').format(doc.expiresAt!)}';
    return switch (doc.status) {
      'verified' => 'Verified$expiry',
      'uploaded' => 'Under review$expiry',
      'rejected' => 'Rejected — upload a new copy',
      _ => 'Not uploaded yet',
    };
  }

  Color _color(String status) => switch (status) {
    'verified' => AppColors.success,
    'uploaded' => AppColors.accent,
    'rejected' => AppColors.error,
    _ => AppColors.warning,
  };

  IconData _icon(String key) => switch (key) {
    'license' => Icons.badge_outlined,
    'registration' => Icons.directions_car_outlined,
    _ => Icons.person_outline,
  };
}
