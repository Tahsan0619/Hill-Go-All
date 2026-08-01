import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _picker = ImagePicker();

  final _businessName = TextEditingController();
  final _description = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();

  static const _categories = [
    'Restaurant & Cafe',
    'Grocery & Market',
    'Bakery',
    'Electronics',
    'Fashion & Apparel',
    'Home & Lifestyle',
    'Health & Beauty',
    'Other',
  ];

  static const _subOptions = {
    'Restaurant & Cafe': ['Fast Casual', 'Fine Dining', 'Coffee', 'Delivery Only'],
    'Grocery & Market': ['Organic', 'Produce', 'Specialty', 'Convenience'],
    'Bakery': ['Bread', 'Pastries', 'Cakes', 'Gluten-Free'],
    'Electronics': ['Audio', 'Accessories', 'Computers', 'Mobile'],
    'Fashion & Apparel': ['Men', 'Women', 'Kids', 'Accessories'],
    'Home & Lifestyle': ['Decor', 'Furniture', 'Kitchen', 'Garden'],
    'Health & Beauty': ['Skincare', 'Wellness', 'Haircare', 'Supplements'],
    'Other': ['General Retail', 'Services', 'Local Maker'],
  };

  @override
  void initState() {
    super.initState();
    final data = context.read<AuthProvider>().onboarding;
    _businessName.text = data.businessName;
    _description.text = data.description;
    _contactName.text = data.contactName;
    _phone.text = data.phone;
    _email.text = data.email;
    _address.text = data.address;
    _city.text = data.city;
    _zip.text = data.zip;
  }

  @override
  void dispose() {
    _businessName.dispose();
    _description.dispose();
    _contactName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _city.dispose();
    _zip.dispose();
    super.dispose();
  }

  void _syncToProvider() {
    final auth = context.read<AuthProvider>();
    final d = auth.onboarding;
    d.businessName = _businessName.text;
    d.description = _description.text;
    d.contactName = _contactName.text;
    d.phone = _phone.text;
    d.email = _email.text;
    d.address = _address.text;
    d.city = _city.text;
    d.zip = _zip.text;
    auth.notifyOnboardingChanged();
  }

  static const _maxImageBytes = 5 * 1024 * 1024;

  Future<void> _pickImage(bool logo) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    final length = await file.length();
    if (!mounted) return;
    if (length > _maxImageBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image must be 5 MB or smaller')),
      );
      return;
    }
    final d = context.read<AuthProvider>().onboarding;
    if (logo) {
      d.logoPath = file.path;
    } else {
      d.storefrontPath = file.path;
    }
    context.read<AuthProvider>().notifyOnboardingChanged();
  }

  Future<void> _continue() async {
    _syncToProvider();
    final auth = context.read<AuthProvider>();
    final d = auth.onboarding;

    if (_step == 0 && !d.step1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill business name and description')),
      );
      return;
    }
    if (_step == 1 && !d.step2Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business category')),
      );
      return;
    }
    if (_step == 2) {
      if (!d.step3Valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all contact fields')),
        );
        return;
      }
      final ok = await auth.completeOnboarding();
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted! HillGo will review it shortly.'),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Failed to complete onboarding')),
        );
      }
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      context.read<AuthProvider>().logout();
      context.go('/login');
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final d = auth.onboarding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        title: Row(
          children: [
            Text('HillGo', style: AppTextStyles.brand),
            const Spacer(),
            Text(
              'MERCHANT ONBOARDING',
              style: AppTextStyles.caption.copyWith(letterSpacing: 0.8),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: _Stepper(current: _step),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (_step == 0) _buildStep1(d),
                  if (_step == 1) _buildStep2(d),
                  if (_step == 2) _buildStep3(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(dynamic d) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tell us about your business', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text(
                'This is how your brand will appear to customers on HillGo.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              Text('Legal Business Name', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextField(
                controller: _businessName,
                decoration: const InputDecoration(
                  hintText: 'e.g. Hillside Organic Cafe',
                ),
                onChanged: (_) => _syncToProvider(),
              ),
              const SizedBox(height: 14),
              Text('Short Description', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tell customers what makes your business special...',
                ),
                onChanged: (_) => _syncToProvider(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _UploadBox(
                      label: 'Upload Logo',
                      icon: Icons.add_a_photo_outlined,
                      path: d.logoPath as String?,
                      onTap: () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UploadBox(
                      label: 'Storefront Photo',
                      icon: Icons.landscape_outlined,
                      path: d.storefrontPath as String?,
                      onTap: () => _pickImage(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.chevron_right,
                loading: context.watch<AuthProvider>().isLoading,
                onPressed: _continue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reach 50k+ Customers\nGain instant visibility in your local neighborhood network.',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            'Join the community of local sellers on HillGo',
            style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(dynamic d) {
    final selected = d.category as String;
    final subs = _subOptions[selected] ?? <String>[];
    final selectedSubs = (d.subcategories as List<String>);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your category', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'Help customers find you in the right aisle of HillGo.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final active = selected == c;
              return ChoiceChip(
                label: Text(c),
                selected: active,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: active ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  d.category = c;
                  d.subcategories = <String>[];
                  context.read<AuthProvider>().notifyOnboardingChanged();
                },
              );
            }).toList(),
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Specialties (optional)', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subs.map((s) {
                final active = selectedSubs.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: active,
                  selectedColor: AppColors.accentSoft,
                  checkmarkColor: AppColors.accent,
                  onSelected: (v) {
                    if (v) {
                      selectedSubs.add(s);
                    } else {
                      selectedSubs.remove(s);
                    }
                    context.read<AuthProvider>().notifyOnboardingChanged();
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.chevron_right,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact & location', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'We’ll use this to verify your store and send order alerts.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 20),
          Text('Contact Name', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _contactName,
            decoration: const InputDecoration(hintText: 'Owner or manager name'),
            onChanged: (_) => _syncToProvider(),
          ),
          const SizedBox(height: 12),
          Text('Phone', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+8801XXXXXXXXX'),
            onChanged: (_) => _syncToProvider(),
          ),
          const SizedBox(height: 12),
          Text('Business Email', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'orders@yourstore.com'),
            onChanged: (_) => _syncToProvider(),
          ),
          const SizedBox(height: 12),
          Text('Street Address', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _address,
            decoration: const InputDecoration(hintText: '128 Urban Center Dr'),
            onChanged: (_) => _syncToProvider(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('City', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _city,
                      decoration:
                          const InputDecoration(hintText: 'e.g. Bandarban'),
                      onChanged: (_) => _syncToProvider(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ZIP', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _zip,
                      decoration: const InputDecoration(hintText: '4600'),
                      onChanged: (_) => _syncToProvider(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Submit for Review',
            icon: Icons.check,
            loading: context.watch<AuthProvider>().isLoading,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    const labels = ['Business', 'Category', 'Contact'];
    return Row(
      children: List.generate(3, (i) {
        final active = i <= current;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i <= current
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.cardBorder,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (i < 2)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < current
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: AppTextStyles.caption.copyWith(
                  color: active ? AppColors.primary : AppColors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.label,
    required this.icon,
    required this.onTap,
    this.path,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: AppColors.textMuted,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: path != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(path!), fit: BoxFit.cover),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.textMuted),
                  const SizedBox(height: 6),
                  Text(label, style: AppTextStyles.caption),
                ],
              ),
      ),
    );
  }
}
