import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

/// Phone + OTP login (primary HillGo Rider auth).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final phone = _phone.text.trim();
    final ok = await auth.sendOtp(phone);
    if (!mounted) return;
    if (ok) {
      context.go('/otp', extra: phone);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.two_wheeler,
                    color: AppColors.primaryDeep,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'HillGo Rider',
                  style: AppTextStyles.display.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go online, accept Ride / Food / Parcel jobs, and earn ৳ in Dhaka.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 36),
                Text(
                  'Phone number',
                  style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 8),
                FormField<String>(
                  validator: (_) {
                    final d = _phone.text.replaceAll(RegExp(r'\D'), '');
                    if (d.length < 10) return 'Enter a valid mobile number';
                    return null;
                  },
                  builder: (field) {
                    final focused = _phoneFocus.hasFocus;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: field.hasError
                                  ? AppColors.tips
                                  : focused
                                      ? AppColors.primary
                                      : AppColors.border,
                              width: focused || field.hasError ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 78,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.cardBlueTint,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(13),
                                  ),
                                ),
                                child: Text(
                                  '+880',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 56, color: AppColors.border),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: TextField(
                                    controller: _phone,
                                    focusNode: _phoneFocus,
                                    keyboardType: TextInputType.phone,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: '17XXXXXXXX',
                                      hintStyle: AppTextStyles.bodySecondary,
                                    ),
                                    onChanged: (_) {
                                      if (field.hasError) field.validate();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (field.hasError) ...[
                          const SizedBox(height: 6),
                          Text(
                            field.errorText!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.tips),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Send OTP',
                  loading: auth.isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('New rider? Create an account'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'By continuing you agree to HillGo Rider terms.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
