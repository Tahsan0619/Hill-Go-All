import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/onboarding/registration');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join HillGo Rider', style: AppTextStyles.headline),
                const SizedBox(height: 8),
                Text(
                  'Register as a delivery partner. We’ll verify your details before you go online.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full name',
                  controller: _name,
                  hint: 'Karim Rahman',
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Email (optional)',
                  controller: _email,
                  hint: 'you@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v != null && v.trim().isNotEmpty && !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Phone',
                  controller: _phone,
                  hint: '01712345678',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 10 ? 'Enter a valid BD mobile number' : null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscure: _obscure,
                  validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Continue', loading: auth.isLoading, onPressed: _submit),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Sign in'),
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
