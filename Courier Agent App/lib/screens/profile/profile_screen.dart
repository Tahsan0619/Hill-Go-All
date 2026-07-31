import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<ProfileProvider>().load(); }); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HillGoAppBar(showMenu: true, onBell: () => context.push('/notifications')),
    body: Consumer<ProfileProvider>(builder: (context, provider, _) {
      if (provider.loading) return const LoadingView(message: 'Loading profile...');
      if (provider.error != null) return ErrorView(message: provider.error!, onRetry: provider.load);
      final user = provider.profile;
      if (user == null) return const EmptyView(message: 'Profile not available.');
      return ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        Center(child: Column(children: [
          CircleAvatar(radius: 44, backgroundImage: user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!), child: user.avatarUrl == null ? const Icon(Icons.person, size: 42) : null),
          const SizedBox(height: 10),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(user.name, style: AppTextStyles.h2),
            if (user.isVerified) ...[const SizedBox(width: 6), const Icon(Icons.verified, color: AppColors.verified, size: 20)],
          ]),
          Text('Partner since ${user.partnerSince}', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            StatusChip(label: '${user.rating} ★', fg: AppColors.accent, bg: AppColors.accentSoft),
            StatusChip(label: '${user.totalDeliveries} deliveries', fg: AppColors.primary, bg: const Color(0xFFE8F1FB)),
          ]),
        ])),
        const SizedBox(height: AppSpacing.xl),
        Row(children: [
          Expanded(child: _stat('Today earnings', '৳${provider.todayEarnings.toStringAsFixed(2)}', Icons.payments_outlined)),
          const SizedBox(width: 12), Expanded(child: _stat('Wallet balance', '৳${provider.balance.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined)),
        ]),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Fleet & Security'), const SizedBox(height: 8),
        _nav('Vehicle Info', user.vehicleName.isEmpty && user.vehiclePlate.isEmpty ? 'Add your vehicle details' : '${user.vehicleName} · ${user.vehiclePlate}', Icons.two_wheeler_outlined, '/profile/vehicle'),
        _nav('Document Status', _kycLabel(user.kycStatus), Icons.verified_user_outlined, '/profile/documents'),
        const SizedBox(height: AppSpacing.lg), const SectionLabel('Preferences'), const SizedBox(height: 8),
        _nav('Notification Preferences', 'Parcel and payout alerts', Icons.notifications_outlined, '/profile/notifications'),
        _nav('App Language', provider.language == 'bn' ? 'বাংলা' : 'English', Icons.language_outlined, '/profile/language'),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () async { await context.read<AuthProvider>().logout(); if (context.mounted) context.go('/login'); },
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, backgroundColor: AppColors.errorBg, side: BorderSide.none, minimumSize: const Size.fromHeight(52)),
          icon: const Icon(Icons.logout), label: const Text('Log out'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(child: Text('App Version 1.0.0', style: AppTextStyles.caption)),
      ]);
    }),
  );

  String _kycLabel(String status) => switch (status) {
    'verified' => 'All documents verified',
    'uploaded' => 'Documents under review',
    'rejected' => 'Action needed — a document was rejected',
    _ => 'Upload your documents to get verified',
  };
  Widget _stat(String label, String value, IconData icon) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.accent), const SizedBox(height: 8), Text(label, style: AppTextStyles.caption), Text(value, style: AppTextStyles.amountSm)]));
  Widget _nav(String title, String subtitle, IconData icon, String route) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppCard(onTap: () => context.push(route), padding: EdgeInsets.zero, child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title, style: AppTextStyles.h3), subtitle: Text(subtitle, style: AppTextStyles.caption), trailing: const Icon(Icons.chevron_right))),
  );
}
