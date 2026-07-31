import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../theme/app_theme.dart';
import 'hillgo_cart_logo.dart';

/// Branded HillGo cart button with a live badge for food + marketplace counts.
class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    required this.onTap,
    this.size = 44,
    this.logoSize,
    this.backgroundColor,
    this.borderColor,
    this.logoColor,
    this.accentColor,
    this.showFood = true,
    this.showMarket = true,
    this.emphasized = false,
    @Deprecated('Use logoSize') double? iconSize,
    @Deprecated('Use logoColor') Color? iconColor,
  })  : _legacyLogoSize = iconSize,
        _legacyLogoColor = iconColor;

  final VoidCallback onTap;
  final double size;
  final double? logoSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? logoColor;
  final Color? accentColor;
  final bool showFood;
  final bool showMarket;

  /// Stronger navy fill + white logo for hero headers.
  final bool emphasized;

  final double? _legacyLogoSize;
  final Color? _legacyLogoColor;

  double get _resolvedLogoSize => logoSize ?? _legacyLogoSize ?? size * 0.52;
  Color? get _resolvedLogoColor => logoColor ?? _legacyLogoColor;

  @override
  Widget build(BuildContext context) {
    final colors = HillGoColors.of(context);
    final listenables = <Listenable>[
      if (showFood) FoodCartStore.revision,
      if (showMarket) MarketplaceCartStore.revision,
    ];

    return AnimatedBuilder(
      animation: listenables.isEmpty
          ? const AlwaysStoppedAnimation(0)
          : Listenable.merge(listenables),
      builder: (context, _) {
        final count = (showFood ? FoodCartStore.itemCount : 0) +
            (showMarket ? MarketplaceCartStore.itemCount : 0);
        final bg = emphasized
            ? AppColors.primaryNavy
            : (backgroundColor ?? colors.surface);
        final border = emphasized
            ? AppColors.primaryNavy
            : (borderColor ?? colors.cardBorder);
        final markColor = emphasized
            ? AppColors.white
            : (_resolvedLogoColor ?? AppColors.primaryNavy);
        final markAccent = emphasized
            ? AppColors.brandLime
            : (accentColor ?? AppColors.accentOrange);

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: emphasized ? 0.16 : 0.06),
                      blurRadius: emphasized ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: HillGoCartLogo(
                  size: _resolvedLogoSize,
                  color: markColor,
                  accentColor: markAccent,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
