import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/catalog_models.dart';
import '../services/api/api_client.dart';
import '../services/api/public_api.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'otp_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _agreedToTerms = false;
  bool _busy = false;

  List<DistrictOption> _districts = [];
  DistrictOption? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await PublicApi.districts();
      if (!mounted) return;
      setState(() {
        _districts =
            districts.where((d) => d.open && d.allowCustomer).toList();
      });
    } on ApiException {
      // District is optional server-side; registration still works without it.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and phone number'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.startRegistration(
        name: name,
        phone: phone,
        email: _emailController.text.trim(),
        districtId: _selectedDistrict?.id,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        OtpVerificationScreen.routeName,
        arguments: phone,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentOrange, Color(0xFFFF9248)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HillGo',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.white,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Create your account',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start your journey today.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Full Name',
                          controller: _nameController,
                          hintText: 'John Doe',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          hintText: '+880 1XXX-XXXXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          hintText: 'you@example.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'District',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<DistrictOption>(
                          initialValue: _selectedDistrict,
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on_outlined,
                                color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.white,
                            hintText: _districts.isEmpty
                                ? 'Loading districts…'
                                : 'Select your district',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.inputBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.inputBorder),
                            ),
                          ),
                          items: [
                            for (final d in _districts)
                              DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d.division == null
                                      ? d.name
                                      : '${d.name} (${d.division})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedDistrict = value),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: AppColors.primaryNavy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) => setState(
                                  () => _agreedToTerms = value ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: textTheme.bodyMedium,
                                    children: const [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: _busy ? 'Sending code…' : 'Create Account',
                          icon: Icons.arrow_forward,
                          backgroundColor: AppColors.primaryNavy,
                          borderRadius: 12,
                          onPressed: _busy ? null : _createAccount,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: AppColors.signUpAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        Navigator.of(context).maybePop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _DeskSilhouettePainter()),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple decorative desk + monitor silhouette used to fill the empty
/// space at the bottom of the registration screen.
class _DeskSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = AppColors.illustrationSky;
    final accentPaint = Paint()..color = AppColors.accentBlueSoft;
    final deskPaint = Paint()..color = const Color(0xFFE0E4EA);
    final monitorPaint = Paint()..color = AppColors.primaryNavy;
    final screenPaint = Paint()..color = AppColors.accentOrangeSoft;

    final centerX = size.width / 2;
    final baseY = size.height * 0.82;

    canvas.drawCircle(
      Offset(centerX, size.height * 0.5),
      size.height * 0.62,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(centerX - size.width * 0.22, size.height * 0.35),
      size.height * 0.18,
      accentPaint,
    );

    final deskRect = Rect.fromLTWH(
      centerX - 90,
      baseY,
      180,
      10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(deskRect, const Radius.circular(4)),
      deskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 78, baseY + 10, 8, 26),
      deskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX + 70, baseY + 10, 8, 26),
      deskPaint,
    );

    final monitorBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 44, baseY - 62, 88, 58),
      const Radius.circular(8),
    );
    canvas.drawRRect(monitorBody, monitorPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 36, baseY - 54, 72, 42),
        const Radius.circular(4),
      ),
      screenPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 6, baseY - 4, 12, 12),
      monitorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 26, baseY + 8, 52, 6),
        const Radius.circular(3),
      ),
      monitorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
