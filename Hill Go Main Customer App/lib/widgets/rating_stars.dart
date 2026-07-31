import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Displays a 5-star rating. When [onChanged] is provided the stars become
/// tappable, which is used on the ride rating screen.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = AppColors.accentOrange,
    this.onChanged,
  });

  final double rating;
  final double size;
  final Color color;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.floor();
        final half = !filled && index < rating;
        final icon = filled
            ? Icons.star_rounded
            : half
                ? Icons.star_half_rounded
                : Icons.star_border_rounded;

        final star = Icon(icon, color: color, size: size);

        if (onChanged == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: star,
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged!(index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: star,
          ),
        );
      }),
    );
  }
}
