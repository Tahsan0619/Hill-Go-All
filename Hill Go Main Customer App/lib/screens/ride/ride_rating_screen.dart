import 'package:flutter/material.dart';

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

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your feedback!'), duration: Duration(seconds: 1)),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    'How was your trip with Rakib?',
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
              label: 'Submit',
              backgroundColor: AppColors.primaryNavy,
              borderRadius: 14,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
