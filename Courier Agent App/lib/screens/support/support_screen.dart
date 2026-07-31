import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}
class _SupportScreenState extends State<SupportScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  @override
  void dispose() { _subject.dispose(); _message.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HillGoAppBar(title: 'Contact Support', showBack: true, showBell: false),
    body: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
      AppCard(color: const Color(0xFFE8F1FB), child: Row(children: [
        const Icon(Icons.support_agent_outlined, color: AppColors.primary, size: 32), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Need urgent help?', style: AppTextStyles.h3), Text('Our team is available 24/7.', style: AppTextStyles.bodySecondary)])),
        IconButton(onPressed: () => launchUrl(Uri.parse('tel:+15550100')), icon: const Icon(Icons.phone, color: AppColors.primary)),
      ])),
      const SizedBox(height: AppSpacing.xl),
      Form(key: _form, child: Column(children: [
        TextFormField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject'), validator: _required),
        const SizedBox(height: 16),
        TextFormField(controller: _message, minLines: 5, maxLines: 7, decoration: const InputDecoration(labelText: 'How can we help?'), validator: _required),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Send message', icon: Icons.send_outlined, onPressed: () {
          if (!_form.currentState!.validate()) return;
          _subject.clear(); _message.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your support message has been sent.')));
        }),
      ])),
    ]),
  );
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Please complete this field' : null;
}
