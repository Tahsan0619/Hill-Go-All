import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/wallet_api.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';

class RewardsCenterScreen extends StatefulWidget {
  const RewardsCenterScreen({super.key});

  static const String routeName = '/rewards';

  @override
  State<RewardsCenterScreen> createState() => _RewardsCenterScreenState();
}

class _RewardsCenterScreenState extends State<RewardsCenterScreen> {
  bool _loading = true;
  String? _error;
  WalletSummary? _summary;
  List<LoyaltyReward> _rewards = [];

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
        WalletApi.rewards(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as WalletSummary;
        _rewards = results[1] as List<LoyaltyReward>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _redeem(LoyaltyReward reward) async {
    final points = _summary?.loyaltyPoints ?? AuthService.user.loyaltyPoints;
    if (points < reward.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough points for "${reward.title}"'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    try {
      await WalletApi.redeem(reward.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redeemed "${reward.title}"'),
          duration: const Duration(seconds: 1),
        ),
      );
      await AuthService.refreshUser();
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final points = _summary?.loyaltyPoints ?? AuthService.user.loyaltyPoints;
    final tiers = _summary?.tiers ?? const <LoyaltyTier>[];
    final currentTierName = _summary?.tier ?? AuthService.user.tier;
    final nextName = _summary?.nextTierName;
    final nextThreshold = _summary?.nextTierThreshold;

    LoyaltyTier? currentTier;
    for (final t in tiers) {
      if (t.name == currentTierName) currentTier = t;
    }
    currentTier ??= tiers.isNotEmpty ? tiers.first : null;

    final progress = nextThreshold == null || currentTier == null
        ? 1.0
        : ((points - currentTier.threshold) /
                (nextThreshold - currentTier.threshold))
            .clamp(0.0, 1.0);

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
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? LoadErrorView(message: _error!, onRetry: _load)
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.accentOrange,
                                          Color(0xFFFF9248)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.stars_rounded,
                                                color: AppColors.white,
                                                size: 26),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Your Points',
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '$points pts',
                                          style: textTheme.headlineLarge
                                              ?.copyWith(fontSize: 34),
                                        ),
                                        const SizedBox(height: 16),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 8,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.3),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(AppColors.white),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          nextName == null ||
                                                  nextThreshold == null
                                              ? "You've reached the top tier!"
                                              : '${nextThreshold - points} pts to $nextName',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.white
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (tiers.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Text('Membership Tiers',
                                        style: textTheme.titleLarge
                                            ?.copyWith(fontSize: 18)),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 96,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: tiers.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final tier = tiers[index];
                                          final isActive =
                                              tier.name == currentTierName;
                                          return Container(
                                            width: 92,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? AppColors.primaryNavy
                                                  : AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isActive
                                                    ? AppColors.primaryNavy
                                                    : AppColors.cardBorder,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .workspace_premium_outlined,
                                                  size: 24,
                                                  color: isActive
                                                      ? AppColors.white
                                                      : AppColors.textMuted,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  tier.name,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: isActive
                                                        ? AppColors.white
                                                        : AppColors
                                                            .textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '${tier.threshold}+',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: isActive
                                                        ? AppColors.white
                                                            .withValues(
                                                                alpha: 0.8)
                                                        : AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Text(
                                    'Redeem Rewards',
                                    style: textTheme.titleLarge
                                        ?.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_rewards.isEmpty)
                                    const EmptyView(
                                      icon: Icons.card_giftcard_outlined,
                                      message: 'No rewards available right now.',
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _rewards.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final reward = _rewards[index];
                                        final canRedeem =
                                            points >= reward.points;
                                        return Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppColors.cardBorder),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 46,
                                                height: 46,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .accentOrangeSoft,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(reward.icon,
                                                    size: 22,
                                                    color: AppColors
                                                        .accentOrange),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      reward.title,
                                                      style: textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(reward.description,
                                                        style: textTheme
                                                            .bodyMedium),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${reward.points} pts',
                                                      style: textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                        color: AppColors
                                                            .primaryNavy,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _redeem(reward),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: canRedeem
                                                      ? AppColors.primaryNavy
                                                      : AppColors.cardBorder,
                                                  foregroundColor: canRedeem
                                                      ? AppColors.white
                                                      : AppColors.textMuted,
                                                  elevation: 0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 10),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
