import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/spacing.dart';
import '../../widgets/common_widgets.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});
  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}
class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _plate;
  String _type = 'Motorbike';
  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: user?.vehicleName ?? '');
    _plate = TextEditingController(text: user?.vehiclePlate ?? '');
    const allowed = ['Motorbike', 'Bicycle', 'Van'];
    if (allowed.contains(user?.vehicleType)) _type = user!.vehicleType;
  }
  @override
  void dispose() { _name.dispose(); _plate.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Scaffold(appBar: const HillGoAppBar(title: 'Vehicle Info', showBack: true, showBell: false), body: Form(
      key: _form, child: ListView(padding: const EdgeInsets.all(AppSpacing.screenPadding), children: [
        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Vehicle name'), validator: _required),
        const SizedBox(height: 16),
        TextFormField(controller: _plate, decoration: const InputDecoration(labelText: 'License plate'), validator: _required),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Vehicle type'), items: const ['Motorbike', 'Bicycle', 'Van'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _type = v!)),
        const SizedBox(height: 28),
        PrimaryButton(label: 'Save vehicle details', loading: provider.loading, onPressed: () async {
          if (!_form.currentState!.validate()) return;
          final messenger = ScaffoldMessenger.of(context);
          final nav = Navigator.of(context);
          final ok = await provider.updateVehicle(name: _name.text.trim(), plate: _plate.text.trim(), type: _type);
          if (!mounted) return;
          if (!ok) {
            messenger.showSnackBar(SnackBar(content: Text(provider.error ?? 'Could not save vehicle details.')));
            return;
          }
          messenger.showSnackBar(const SnackBar(content: Text('Vehicle details saved.')));
          nav.pop();
        }),
      ]),
    ));
  }
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;
}
