import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rides_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';

class RideRatingScreen extends StatefulWidget {
  const RideRatingScreen({super.key});

  static const String routeName = '/ride/rating';

  @override
  State<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends State<RideRatingScreen> {
  int _rating = 5;
  bool _submitting = false;
  final _commentController = TextEditingController();

  static const _tags = [
    'Clean vehicle',
    'Friendly driver',
    'Safe driving',
    'On time',
    'Great music',
    'Smooth ride',
  ];

  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(RideEntry ride) async {
    setState(() => _submitting = true);
    final comment = [
      if (_selectedTags.isNotEmpty) _selectedTags.join(', '),
      if (_commentController.text.trim().isNotEmpty) _commentController.text.trim(),
    ].join(' — ');
    try {
      await RidesApi.rate(ride.id, rating: _rating, comment: comment.isEmpty ? null : comment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your feedback!'), duration: Duration(seconds: 1)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments;
    final ride = args is RideEntry ? args : null;

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const HillgoAppBar(title: 'Rate your ride'),
        body: Center(child: Text('Ride not found.', style: textTheme.bodyLarge)),
      );
    }

    final driverName = ride.driver?.name ?? 'your driver';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Rate your ride'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accentBlueSoft,
                    child: Icon(Icons.person, color: AppColors.primaryNavy, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How was your trip with $driverName?',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RatingStars(
                    rating: _rating.toDouble(),
                    size: 40,
                    onChanged: (value) => setState(() => _rating = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('What went well?', style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _tags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryNavy,
                  backgroundColor: AppColors.white,
                  side: BorderSide(color: selected ? AppColors.primaryNavy : AppColors.cardBorder),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Add a comment', style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tell us more about your experience (optional)',
                  hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _submitting ? 'Submitting…' : 'Submit',
              backgroundColor: AppColors.primaryNavy,
              borderRadius: 14,
              onPressed: _submitting ? null : () => _submit(ride),
            ),
          ],
        ),
      ),
    );
  }
}
