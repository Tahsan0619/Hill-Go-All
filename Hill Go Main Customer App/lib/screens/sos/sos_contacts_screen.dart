import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/sos_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/primary_button.dart';

class SosContactsScreen extends StatefulWidget {
  const SosContactsScreen({super.key});

  static const String routeName = '/sos/contacts';

  @override
  State<SosContactsScreen> createState() => _SosContactsScreenState();
}

class _SosContactsScreenState extends State<SosContactsScreen> {
  bool _loading = true;
  String? _error;
  List<EmergencyContact> _contacts = [];

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
      await SosService.refresh();
      if (!mounted) return;
      setState(() {
        _contacts = SosService.contacts;
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

  Future<void> _showAddSheet() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController(text: 'Friend');
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add emergency contact',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: relationController,
                    decoration: const InputDecoration(
                      labelText: 'Relation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: saving ? 'Saving…' : 'Save contact',
                    backgroundColor: const Color(0xFFE53935),
                    borderRadius: 14,
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            if (name.isEmpty || phone.isEmpty) return;
                            setSheetState(() => saving = true);
                            try {
                              await SosService.addContact(
                                name: name,
                                phone: phone,
                                relation:
                                    relationController.text.trim().isEmpty
                                        ? 'Contact'
                                        : relationController.text.trim(),
                              );
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (mounted) {
                                setState(
                                    () => _contacts = SosService.contacts);
                              }
                            } on ApiException catch (e) {
                              setSheetState(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(e.message)),
                                );
                              }
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _remove(EmergencyContact contact) async {
    try {
      await SosService.removeContact(contact.id);
      if (!mounted) return;
      setState(() => _contacts = SosService.contacts);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(
                title: 'Emergency contacts',
                subtitle: 'Who we alert in SOS',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? LoadErrorView(message: _error!, onRetry: _load)
                        : _contacts.isEmpty
                            ? Center(
                                child: Text(
                                  'No emergency contacts yet.',
                                  style: textTheme.bodyLarge,
                                ),
                              )
                            : ListView.separated(
                                itemCount: _contacts.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final c = _contacts[index];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFEBEE),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                style: textTheme.bodyLarge
                                                    ?.copyWith(
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
                                        IconButton(
                                          onPressed: () => _remove(c),
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              color: Color(0xFFE53935)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Add contact',
                backgroundColor: const Color(0xFFE53935),
                borderRadius: 14,
                icon: Icons.person_add_alt_1,
                onPressed: _showAddSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
