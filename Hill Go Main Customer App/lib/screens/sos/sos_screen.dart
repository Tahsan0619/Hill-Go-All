import 'package:flutter/material.dart';

import '../../services/sos_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';
import 'sos_contacts_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key, this.initialContext});

  static const String routeName = '/sos';

  /// Optional label such as "Ride SOS" when opened from live tracking.
  final String? initialContext;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _sending = false;
  String? _lastMessage;

  Future<void> _trigger(String type) async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _lastMessage = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final message = SosService.triggerAlert(type: type);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _lastMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final contacts = SosService.contacts;
    final alerts = SosService.alerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(
                title: 'SOS Emergency',
                subtitle: widget.initialContext ?? 'Get help fast',
                actions: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(SosContactsScreen.routeName);
                      setState(() {});
                    },
                    icon: const Icon(Icons.contacts_outlined,
                        color: AppColors.primaryNavy),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _sending
                            ? null
                            : () => _trigger(
                                  widget.initialContext ?? 'SOS Alert',
                                ),
                        child: Container(
                          width: 180,
                          height: 180,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE53935),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935)
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: _sending
                              ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sos,
                                        color: AppColors.white, size: 48),
                                    SizedBox(height: 6),
                                    Text(
                                      'HOLD / TAP',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to alert your emergency contacts\nand share your live location.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                      if (_lastMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _lastMessage!,
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickAction(
                              label: 'Police',
                              icon: Icons.local_police_outlined,
                              color: AppColors.primaryNavy,
                              onTap: () => _trigger('Police call request'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickAction(
                              label: 'Ambulance',
                              icon: Icons.medical_services_outlined,
                              color: const Color(0xFFE53935),
                              onTap: () => _trigger('Ambulance request'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickAction(
                              label: 'Share pin',
                              icon: Icons.my_location,
                              color: AppColors.accentOrange,
                              onTap: () => _trigger('Location shared'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            'Emergency contacts',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushNamed(SosContactsScreen.routeName);
                              setState(() {});
                            },
                            child: const Text('Manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (contacts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            'No contacts yet. Add someone who can help in an emergency.',
                            style: textTheme.bodyMedium,
                          ),
                        )
                      else
                        ...contacts.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: Color(0xFFE53935)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${c.relation} · ${c.phone}',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent alerts',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...alerts.take(3).map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Color(0xFFE53935), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.type,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(a.timeLabel,
                                              style: textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      a.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: a.status == 'Active'
                                            ? const Color(0xFFE53935)
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Send SOS now',
                        backgroundColor: const Color(0xFFE53935),
                        borderRadius: 14,
                        onPressed: _sending
                            ? null
                            : () => _trigger(
                                  widget.initialContext ?? 'SOS Alert',
                                ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
