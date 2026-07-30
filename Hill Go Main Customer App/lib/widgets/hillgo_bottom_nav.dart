import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HillGoBottomNavItemData {
  const HillGoBottomNavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<HillGoBottomNavItemData> hillGoBottomNavItems = [
  HillGoBottomNavItemData(label: 'Home', icon: Icons.home_rounded),
  HillGoBottomNavItemData(label: 'Activity', icon: Icons.receipt_long_rounded),
  HillGoBottomNavItemData(label: 'Market', icon: Icons.storefront_rounded),
  HillGoBottomNavItemData(label: 'Chat', icon: Icons.chat_bubble_rounded),
  HillGoBottomNavItemData(label: 'Profile', icon: Icons.person_rounded),
];

/// Icon-only bottom navigation. Active tab uses a navy pill; icons stay
/// centered in equal-width slots across the full bar.
class HillGoBottomNav extends StatelessWidget {
  const HillGoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HillGoColors.of(context);

    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          width: double.infinity,
          child: Row(
            children: List.generate(hillGoBottomNavItems.length, (index) {
              final item = hillGoBottomNavItems[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 48,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryNavy
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        item.icon,
                        size: 24,
                        color: isActive ? AppColors.white : colors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
