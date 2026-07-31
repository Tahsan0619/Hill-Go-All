import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/profile_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/primary_button.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  static const String routeName = '/wallet/payment-methods';

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _loading = true;
  String? _error;
  List<PaymentMethodEntry> _methods = [];
  int? _selectedId;

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
      final rows = await ProfileApi.paymentMethods();
      if (!mounted) return;
      setState(() {
        _methods = rows;
        PaymentMethodEntry? preferred;
        for (final m in rows) {
          if (m.isDefault) {
            preferred = m;
            break;
          }
        }
        preferred ??= rows.isEmpty ? null : rows.first;
        _selectedId = preferred?.id;
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

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _addMethod() async {
    String type = 'bkash';
    final labelController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add payment method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final option in const [
                    ('bkash', 'bKash'),
                    ('nagad', 'Nagad'),
                    ('card', 'Card'),
                    ('wallet', 'Wallet'),
                  ])
                    ChoiceChip(
                      label: Text(option.$2),
                      selected: type == option.$1,
                      onSelected: (_) =>
                          setDialogState(() => type = option.$1),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g. Personal bKash',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    final label = labelController.text.trim();
    if (label.isEmpty) {
      _snack('Label is required');
      return;
    }
    try {
      final created = await ProfileApi.addPaymentMethod(
        type: type,
        label: label,
        isDefault: _methods.isEmpty,
      );
      if (!mounted) return;
      setState(() {
        _methods = [..._methods, created];
        _selectedId ??= created.id;
      });
    } on ApiException catch (e) {
      _snack(e.message);
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
              const AppBackBar(title: 'Payment Methods'),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? LoadErrorView(message: _error!, onRetry: _load)
                        : _methods.isEmpty
                            ? const EmptyView(
                                icon: Icons.credit_card_outlined,
                                message: 'No payment methods saved yet.',
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: _methods.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final method = _methods[index];
                                    final selected = method.id == _selectedId;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => setState(
                                          () => _selectedId = method.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.primaryNavy
                                                : AppColors.cardBorder,
                                            width: selected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: method.iconColor
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(method.icon,
                                                  size: 22,
                                                  color: method.iconColor),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    method.label,
                                                    style: textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: AppColors
                                                          .textPrimary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  if (method.subtitle
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(method.subtitle,
                                                        style: textTheme
                                                            .bodyMedium),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              selected
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_off,
                                              color: selected
                                                  ? AppColors.primaryNavy
                                                  : AppColors.textMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Add Method',
                icon: Icons.add,
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: _addMethod,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
