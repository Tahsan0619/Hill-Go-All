import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/wallet_api.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/user_facing_error.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/transaction_tile.dart';
import 'payment_method_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.showBack = true});

  static const String routeName = '/wallet';

  final bool showBack;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _loading = true;
  String? _error;
  WalletSummary? _summary;
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        WalletApi.summary(),
        WalletApi.transactions(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as WalletSummary;
        _transactions = results[1] as List<WalletTransaction>;
        _loading = false;
      });
      await AuthService.refreshUser();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
    }
  }

  Future<void> _topUp() async {
    final controller = TextEditingController(text: '500');
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add money'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (৳)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, value);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0 || !mounted) return;
    if (amount < 10 || amount > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount between ৳10 and ৳50,000')),
      );
      return;
    }
    try {
      final message =
          await WalletApi.topUp(amount: amount, method: 'bkash');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final balance = _summary?.balance ?? AuthService.user.walletBalance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBack)
                AppBackBar(
                  title: 'My Wallet',
                  actions: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodScreen(),
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.credit_card_outlined,
                          color: AppColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Text(
                      'HillGo Wallet',
                      style: textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        PaymentMethodScreen.routeName,
                      ),
                      icon: const Icon(
                        Icons.credit_card_outlined,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              if (widget.showBack) const SizedBox(height: 8),
              const SizedBox(height: 20),
              if (_loading)
                const Expanded(child: LoadingView())
              else if (_error != null)
                Expanded(child: LoadErrorView(message: _error!, onRetry: _load))
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryNavy, Color(0xFF00306B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳${balance.toStringAsFixed(2)}',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 34,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _WalletActionButton(
                              icon: Icons.add,
                              label: 'Add Money',
                              onTap: _topUp,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _WalletActionButton(
                              icon: Icons.north_east,
                              label: 'Send',
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Peer transfers coming soon',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: _transactions.isEmpty
                      ? const EmptyView(
                          icon: Icons.receipt_long_outlined,
                          message: 'No transactions yet.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: AppColors.cardBorder),
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return TransactionTile(
                                title: transaction.title,
                                dateLabel: transaction.dateLabel,
                                amount: transaction.amount,
                                isCredit: transaction.isCredit,
                                icon: transaction.icon,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  const _WalletActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
