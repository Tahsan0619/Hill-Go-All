import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/fare_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/hillgo_map.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _mapController = MapController();
  static const _center = LatLng(DhakaMap.lat, DhakaMap.lng);
  Timer? _offerPoll;
  bool _watching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final driver = context.read<DriverProvider>();
      // Match local toggle to backend presence so offer polling actually runs.
      driver.restoreOnlineFromProfile(auth.user?.isOnline ?? false);
      await driver.loadDashboard();
      if (!mounted) return;
      _syncOfferWatch(driver);
      if (driver.activeTrip != null) {
        context.push('/trip/navigation');
      } else if (driver.isOnline && driver.incomingOffer != null) {
        context.push('/trip/offer');
      }
    });
  }

  @override
  void dispose() {
    _offerPoll?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _syncOfferWatch(DriverProvider driver) {
    final shouldWatch = driver.isOnline && driver.activeTrip == null;
    if (!shouldWatch) {
      _offerPoll?.cancel();
      _offerPoll = null;
      _watching = false;
      return;
    }
    if (_watching && _offerPoll != null) return;
    _watching = true;
    _offerPoll?.cancel();
    _offerPoll = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      final d = context.read<DriverProvider>();
      if (!d.isOnline || d.activeTrip != null) {
        _syncOfferWatch(d);
        return;
      }
      if (d.incomingOffer != null) return;
      await d.refreshOffer();
      if (!mounted) return;
      if (d.incomingOffer != null) {
        context.push('/trip/offer');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final user = context.watch<AuthProvider>().user;
    final earnings = driver.earnings;
    _syncOfferWatch(driver);

    return Scaffold(
      body: Stack(
        children: [
          HillGoMap(
            mapController: _mapController,
            center: _center,
            zoom: 12.2,
            markers: [HillGoMap.driverMarker(_center)],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.menu,
                      onTap: () => _openDrawer(context, user?.name ?? 'Partner'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        driver.isOnline ? "You're Online" : 'Go Online',
                        style: AppTextStyles.titleBlue,
                      ),
                    ),
                    StatusPill(
                      label: driver.isOnline ? 'ONLINE' : 'OFFLINE',
                      online: driver.isOnline,
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: driver.isOnline,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) async {
                        final ok = await driver.toggleOnline(v);
                        if (!context.mounted) return;
                        if (!ok) {
                          // e.g. KYC not verified yet — surface the server message.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(driver.error ?? 'Could not update status'),
                            ),
                          );
                          return;
                        }
                        _syncOfferWatch(driver);
                        if (v && driver.incomingOffer != null) {
                          context.push('/trip/offer');
                        } else if (v) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("You're online. Waiting for offers…"),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            right: 16,
            child: _RoundIconButton(
              icon: Icons.my_location,
              onTap: () => _mapController.move(_center, 13),
            ),
          ),
          if (driver.isOnline && driver.incomingOffer == null && driver.activeTrip == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6)],
                ),
                child: Text(
                  'Waiting for nearby jobs…',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: driver.isLoading && earnings == null
                  ? const SizedBox(height: 160, child: LoadingView(message: 'Loading earnings…'))
                  : driver.error != null && earnings == null
                      ? SizedBox(
                          height: 160,
                          child: ErrorView(message: driver.error!, onRetry: driver.loadDashboard),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TODAY'S EARNINGS", style: AppTextStyles.labelCaps),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  formatTaka(earnings?.todayTotal ?? 0),
                                  style: AppTextStyles.moneyLarge,
                                ),
                                const SizedBox(width: 10),
                                TrendBadge(
                                  label: '+${(earnings?.todayTrendPercent ?? 0).toStringAsFixed(0)}%',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.work_outline,
                                    label: 'JOBS',
                                    value: '${earnings?.todayTrips ?? 0}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.schedule,
                                    label: 'ONLINE',
                                    value: driver.formatOnlineDuration(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AccentButton(
                              label: 'View Earnings  >',
                              onPressed: () => context.go('/earnings'),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDrawer(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
              title: Text(name, style: AppTextStyles.title),
              subtitle: const Text('HillGo Rider Partner'),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Navigate to offer'),
              onTap: () {
                Navigator.pop(context);
                final offer = context.read<DriverProvider>().incomingOffer;
                if (offer != null) {
                  context.push('/trip/offer');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Go online to receive offers')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Safety'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('For emergencies call 999. Support: support@hillgo.com'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.labelCaps.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
