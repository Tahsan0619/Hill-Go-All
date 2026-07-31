import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      drawer: const _AppDrawer(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  selected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  selected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Icons.payments_outlined,
                  label: 'Earnings',
                  selected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  selected: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : AppColors.navInactive,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? Colors.white : AppColors.navInactive,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text('HillGo Courier', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                  Text(
                    'Urban Logistics, Accelerated.',
                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                context.go('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Earnings'),
              onTap: () {
                Navigator.pop(context);
                context.go('/earnings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_rounded),
              title: const Text('Incentives'),
              onTap: () {
                Navigator.pop(context);
                context.push('/incentives');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: const Text('Contact Support'),
              onTap: () {
                Navigator.pop(context);
                context.push('/support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('Help & Safety'),
              onTap: () {
                Navigator.pop(context);
                context.push('/help');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
