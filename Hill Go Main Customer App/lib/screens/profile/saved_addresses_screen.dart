import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/profile_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/address_card.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/primary_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  static const String routeName = '/profile/addresses';

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  bool _loading = true;
  String? _error;
  List<SavedAddress> _addresses = [];

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
      final rows = await ProfileApi.addresses();
      if (!mounted) return;
      setState(() {
        _addresses = rows;
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

  Future<void> _removeAddress(SavedAddress address) async {
    try {
      await ProfileApi.deleteAddress(address.id);
      if (!mounted) return;
      setState(() => _addresses.removeWhere((a) => a.id == address.id));
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _showAddDialog() async {
    final labelController = TextEditingController(text: 'Home');
    final addressController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
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
    );
    if (saved != true || !mounted) return;
    final label = labelController.text.trim();
    final address = addressController.text.trim();
    if (label.isEmpty || address.isEmpty) {
      _snack('Label and address are required');
      return;
    }
    try {
      final created = await ProfileApi.createAddress(
        label: label,
        address: address,
        isDefault: _addresses.isEmpty,
      );
      if (!mounted) return;
      setState(() => _addresses = [..._addresses, created]);
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
              const AppBackBar(title: 'Saved Addresses'),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? LoadErrorView(message: _error!, onRetry: _load)
                        : _addresses.isEmpty
                            ? Center(
                                child: Text('No saved addresses yet',
                                    style: textTheme.bodyLarge),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: _addresses.length,
                                  itemBuilder: (context, index) {
                                    final address = _addresses[index];
                                    return AddressCard(
                                      label: address.label,
                                      address: address.address,
                                      icon: address.icon,
                                      isDefault: address.isDefault,
                                      onEdit: () => _snack(
                                          'Edit ${address.label} address'),
                                      onDelete: () =>
                                          _removeAddress(address),
                                    );
                                  },
                                ),
                              ),
              ),
              const SizedBox(height: 4),
              PrimaryButton(
                label: 'Add Address',
                icon: Icons.add,
                backgroundColor: AppColors.primaryNavy,
                borderRadius: 14,
                onPressed: _showAddDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
