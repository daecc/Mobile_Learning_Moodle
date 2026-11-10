import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gamification_tier.dart';

/// Widget de avatar de estudiante con marco cosmético dinámico y distintivo de Rango.
class TierAvatar extends StatelessWidget {
  final String initials;
  final GamificationTier tier;
  final double radius;
  final double borderWidth;
  final bool showBadge;

  const TierAvatar({
    super.key,
    required this.initials,
    required this.tier,
    this.radius = 32,
    this.borderWidth = 3.5,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatarWidget = Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: tier.borderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.primaryColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceOf(context),
        child: CircleAvatar(
          radius: radius - 2,
          backgroundColor: tier.primaryColor,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: radius * 0.72,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );

    if (!showBadge) {
      return avatarWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatarWidget,
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: isDark ? tier.primaryColor.withValues(alpha: 0.22) : tier.badgeBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tier.primaryColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tier.icon, size: 13, color: tier.primaryColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Nivel ${tier.level} · ${tier.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : tier.badgeTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
