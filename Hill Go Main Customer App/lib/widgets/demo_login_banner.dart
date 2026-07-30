import 'package:flutter/material.dart';

import '../services/demo_auth_service.dart';
import '../theme/app_theme.dart';

/// Shows demo credentials and a one-tap "Use Demo Account" action.
class DemoLoginBanner extends StatelessWidget {
  const DemoLoginBanner({
    super.key,
    this.onUseDemo,
    this.compact = false,
  });

  final VoidCallback? onUseDemo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.brandLime.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandLime.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, size: 18, color: AppColors.navy),
              SizedBox(width: 8),
              Text(
                'Demo test account',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            _CredentialRow(label: 'Email', value: DemoAuthService.demoEmail),
            _CredentialRow(label: 'Password', value: DemoAuthService.demoPassword),
            _CredentialRow(label: 'Phone', value: DemoAuthService.demoPhone),
            _CredentialRow(label: 'OTP', value: DemoAuthService.demoOtp),
          ],
          if (onUseDemo != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onUseDemo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.primaryNavy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Use Demo Account',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
