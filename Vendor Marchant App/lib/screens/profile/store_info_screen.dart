import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _address;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _desc = TextEditingController();
    _address = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<StoreProvider>();
      if (p.store == null) await p.load();
      final s = p.store;
      if (s != null) {
        _name.text = s.name;
        _desc.text = s.description;
        _address.text = s.address;
      }
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickTime(String day, bool isOpen) async {
    final store = context.read<StoreProvider>().store!;
    final hours = store.hours[day]!;
    final initial = isOpen ? hours.open : hours.close;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      if (isOpen) {
        hours.open = picked;
      } else {
        hours.close = picked;
      }
      if (mounted) {
        context.read<StoreProvider>().touch();
        setState(() {});
      }
    }
  }

  Future<void> _save() async {
    final p = context.read<StoreProvider>();
    final s = p.store!;
    s.name = _name.text.trim();
    s.description = _desc.text.trim();
    s.address = _address.text.trim();
    final ok = await p.saveStore(s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Store saved' : 'Failed to save')),
    );
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final store = provider.store;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: !_ready || store == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    children: [
                      Image.network(
                        store.bannerUrl ??
                            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=320&fit=crop',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.eco,
                                  color: AppColors.accent),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: AppTextStyles.h3
                                      .copyWith(color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.verified,
                                          size: 14, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text('Verified Merchant',
                                          style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('General Information', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Store Name', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(controller: _name),
                      const SizedBox(height: 12),
                      Text('Business Description', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(controller: _desc, maxLines: 3),
                      const SizedBox(height: 12),
                      Text('Store Address', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _address,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Business Hours', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        provider.resetHoursToDefault();
                        setState(() {});
                      },
                      child: Text(
                        'Reset to Default',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                AppCard(
                  child: Column(
                    children: store.hours.entries.map((e) {
                      final day = e.key;
                      final h = e.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(day, style: AppTextStyles.bodyBold),
                            ),
                            if (h.isClosed)
                              Expanded(
                                child: Text(
                                  'Store Closed',
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                              )
                            else ...[
                              _TimeChip(
                                label: _fmt(h.open),
                                onTap: () => _pickTime(day, true),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('to'),
                              ),
                              _TimeChip(
                                label: _fmt(h.close),
                                onTap: () => _pickTime(day, false),
                              ),
                            ],
                            if (day == 'Sunday')
                              Switch(
                                value: !h.isClosed,
                                onChanged: (v) {
                                  h.isClosed = !v;
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('QUICK TOGGLE', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accepting Orders',
                                style: AppTextStyles.bodyBold
                                    .copyWith(color: AppColors.primary)),
                            Text(
                              store.acceptingOrders
                                  ? 'Instant delivery active'
                                  : 'Orders currently paused',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: store.acceptingOrders,
                        onChanged: provider.toggleAcceptingOrders,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            LatLng(store.latitude, store.longitude),
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.babuntoo.vendormarchantapp',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(store.latitude, store.longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    store.latitude += 0.001;
                    store.longitude += 0.001;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location pin updated (mock)'),
                      ),
                    );
                  },
                  child: const Text('Update Location Pin'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: store.profileStrength / 100,
                              strokeWidth: 8,
                              backgroundColor: AppColors.cardBorder,
                              color: AppColors.accent,
                            ),
                            Text(
                              '${store.profileStrength}%',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Profile Strength', style: AppTextStyles.bodyBold),
                      Text(
                        'Add bank details to reach 100%.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: 'Save Changes',
                        loading: provider.isSaving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
