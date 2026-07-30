import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/address_card.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  static const String routeName = '/profile/addresses';

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late final List<SavedAddress> _addresses = List.of(dummyAddresses);

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _removeAddress(SavedAddress address) {
    setState(() => _addresses.remove(address));
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
                child: _addresses.isEmpty
                    ? Center(
                        child: Text('No saved addresses yet', style: textTheme.bodyLarge),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          return AddressCard(
                            label: address.label,
                            address: address.address,
                            icon: address.icon,
                            isDefault: address.isDefault,
                            onEdit: () => _snack('Edit ${address.label} address'),
                            onDelete: () => _removeAddress(address),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 4),
              PrimaryButton(
                label: 'Add Address',
                icon: Icons.add,
                backgroundColor: AppColors.primaryNavy,
                borderRadius: 14,
                onPressed: () => _snack('Add new address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
