import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class BrandingScreen extends StatefulWidget {
  const BrandingScreen({super.key});

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends State<BrandingScreen> {
  late TextEditingController _name;
  late TextEditingController _specialties;
  late TextEditingController _bio;
  String? _bannerLocal;
  String? _logoLocal;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _specialties = TextEditingController();
    _bio = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<StoreProvider>();
      if (p.store == null) await p.load();
      final s = p.store;
      if (s != null) {
        _name.text = s.name;
        _specialties.text = s.specialties;
        _bio.text = s.bio;
        _bannerLocal = s.bannerLocalPath;
        _logoLocal = s.logoLocalPath;
      }
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _specialties.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pick(bool banner) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      if (banner) {
        _bannerLocal = file.path;
      } else {
        _logoLocal = file.path;
      }
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _specialties.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store name and specialties are required')),
      );
      return;
    }
    final p = context.read<StoreProvider>();
    final s = p.store!;
    s.name = _name.text.trim();
    s.specialties = _specialties.text.trim();
    s.bio = _bio.text.trim();
    s.bannerLocalPath = _bannerLocal;
    s.logoLocalPath = _logoLocal;
    final ok = await p.saveStore(s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Branding saved' : 'Failed to save')),
    );
  }

  List<String> get _tags => _specialties.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(3)
      .toList();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: !_ready || store.store == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Store Branding', style: AppTextStyles.h1),
                Text(
                  'Update how your store appears to customers on the HillGo marketplace.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Store Banner', style: AppTextStyles.bodyBold),
                          const Spacer(),
                          Text('Recommended: 1200x400px',
                              style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _pick(true),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.textMuted),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _bannerLocal != null
                              ? Image.file(File(_bannerLocal!),
                                  fit: BoxFit.cover)
                              : store.store!.bannerUrl != null
                                  ? Image.network(store.store!.bannerUrl!,
                                      fit: BoxFit.cover)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_photo_alternate_outlined),
                                        Text('Click to upload banner',
                                            style: AppTextStyles.caption),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _pick(false),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.textMuted),
                                color: const Color(0xFFF3F4F6),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _logoLocal != null
                                  ? Image.file(File(_logoLocal!),
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.add_photo_alternate_outlined),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _name,
                                  decoration: const InputDecoration(
                                    labelText: 'Store Name',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _specialties,
                                  decoration: const InputDecoration(
                                    labelText: 'Specialties (Comma separated)',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bio,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Store Bio',
                          hintText:
                              'Tell your customers about your store, your mission, and what makes you unique...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Customer Preview', style: AppTextStyles.h3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LIVE',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: _bannerLocal != null
                                    ? Image.file(File(_bannerLocal!),
                                        fit: BoxFit.cover)
                                    : store.store!.bannerUrl != null &&
                                            store.store!.bannerUrl!.isNotEmpty
                                        ? Image.network(
                                            store.store!.bannerUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                    color: AppColors.primary),
                                          )
                                        : Container(color: AppColors.primary),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: _logoLocal != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.file(
                                            File(_logoLocal!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.store,
                                          color: AppColors.primary, size: 20),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name.text.isEmpty
                                      ? 'Your Store'
                                      : _name.text,
                                  style: AppTextStyles.bodyBold,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: _tags
                                      .map(
                                        (t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentSoft,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            t,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                    color: AppColors.accent),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: List.generate(
                                    2,
                                    (_) => Expanded(
                                      child: Container(
                                        height: 48,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEEEEE),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preview shows how your branding appears on the HillGo mobile app.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    final s = store.store!;
                    _name.text = s.name;
                    _specialties.text = s.specialties;
                    _bio.text = s.bio;
                    _bannerLocal = s.bannerLocalPath;
                    _logoLocal = s.logoLocalPath;
                    setState(() {});
                  },
                  child: const Text('Discard Changes'),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Save Branding',
                  loading: store.isSaving,
                  onPressed: _save,
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
