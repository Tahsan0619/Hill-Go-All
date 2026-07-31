import 'package:flutter/material.dart';

import '../services/api/api_client.dart';
import '../theme/app_theme.dart';

/// Network image with rounded corners and a graceful icon/color fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.fallbackColor = AppColors.accentBlueSoft,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackIconSize = 36,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiClient.absoluteUrl(imageUrl);
    final hasUrl = resolved != null && resolved.isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: hasUrl
            ? Image.network(
                resolved,
                width: width,
                height: height,
                fit: fit,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _Fallback(
                    color: fallbackColor,
                    icon: fallbackIcon,
                    iconSize: fallbackIconSize,
                  );
                },
                errorBuilder: (_, __, ___) => _Fallback(
                  color: fallbackColor,
                  icon: fallbackIcon,
                  iconSize: fallbackIconSize,
                ),
              )
            : _Fallback(
                color: fallbackColor,
                icon: fallbackIcon,
                iconSize: fallbackIconSize,
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.color,
    required this.icon,
    required this.iconSize,
  });

  final Color color;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primaryNavy, size: iconSize),
    );
  }
}
