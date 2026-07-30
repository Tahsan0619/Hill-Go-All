import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';

class _RewardTier {
  const _RewardTier(this.label, this.minPoints, this.icon);

  final String label;
  final int minPoints;
  final IconData icon;
}

class _RedeemableReward {
  const _RedeemableReward(this.title, this.description, this.points, this.icon);

  final String title;
  final String description;
  final int points;
  final IconData icon;
}

class RewardsCenterScreen extends StatelessWidget {
  const RewardsCenterScreen({super.key});

  static const String routeName = '/rewards';

  static const int _points = 1240;

  static const _tiers = [
    _RewardTier('Bronze', 0, Icons.workspace_premium_outlined),
    _RewardTier('Silver', 1000, Icons.workspace_premium_outlined),
    _RewardTier('Gold', 2000, Icons.workspace_premium_outlined),
    _RewardTier('Platinum', 5000, Icons.workspace_premium_outlined),
  ];

  static const _rewards = [
    _RedeemableReward(
      '\$5 Delivery Voucher',
      'Valid on any parcel or marketplace order',
      500,
      Icons.local_shipping_outlined,
    ),
    _RedeemableReward(
      'Free Delivery Pass',
      'One free delivery on your next order',
      800,
      Icons.card_giftcard_outlined,
    ),
    _RedeemableReward(
      '\$10 Marketplace Coupon',
      'Redeem on any marketplace purchase',
      1200,
      Icons.shopping_bag_outlined,
    ),
    _RedeemableReward(
      'Priority Support',
      '30 days of priority customer support',
      1500,
      Icons.support_agent_outlined,
    ),
  ];

  _RewardTier get _currentTier {
    var tier = _tiers.first;
    for (final t in _tiers) {
      if (_points >= t.minPoints) tier = t;
    }
    return tier;
  }

  _RewardTier? get _nextTier {
    final currentIndex = _tiers.indexOf(_currentTier);
    if (currentIndex + 1 < _tiers.length) return _tiers[currentIndex + 1];
    return null;
  }

  void _redeem(BuildContext context, _RedeemableReward reward) {
    final canRedeem = _points >= reward.points;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          canRedeem
              ? 'Redeemed "${reward.title}"'
              : 'Not enough points for "${reward.title}"',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nextTier = _nextTier;
    final progress = nextTier == null
        ? 1.0
        : (_points - _currentTier.minPoints) /
            (nextTier.minPoints - _currentTier.minPoints);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(title: 'Rewards Center'),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentOrange, Color(0xFFFF9248)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.white, size: 26),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Points',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$_points pts',
                              style: textTheme.headlineLarge?.copyWith(fontSize: 34),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextTier == null
                                  ? "You've reached the top tier!"
                                  : '${nextTier.minPoints - _points} pts to ${nextTier.label}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Membership Tiers', style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _tiers.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final tier = _tiers[index];
                            final isActive = tier.label == _currentTier.label;
                            return Container(
                              width: 92,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primaryNavy : AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive ? AppColors.primaryNavy : AppColors.cardBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tier.icon,
                                    size: 24,
                                    color: isActive ? AppColors.white : AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    tier.label,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: isActive ? AppColors.white : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${tier.minPoints}+',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: isActive
                                          ? AppColors.white.withValues(alpha: 0.8)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Redeem Rewards',
                        style: textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rewards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final reward = _rewards[index];
                          final canRedeem = _points >= reward.points;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrangeSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(reward.icon, size: 22, color: AppColors.accentOrange),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reward.title,
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(reward.description, style: textTheme.bodyMedium),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${reward.points} pts',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.primaryNavy,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _redeem(context, reward),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        canRedeem ? AppColors.primaryNavy : AppColors.cardBorder,
                                    foregroundColor:
                                        canRedeem ? AppColors.white : AppColors.textMuted,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Redeem'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
