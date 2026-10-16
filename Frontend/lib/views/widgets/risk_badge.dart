import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Píldora de color que representa el nivel de riesgo.
class RiskBadge extends StatelessWidget {
  final String nivelRiesgo;
  final String? etiqueta;

  const RiskBadge({super.key, required this.nivelRiesgo, this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLevel(nivelRiesgo);
    final soft = AppColors.softForLevel(nivelRiesgo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        etiqueta ?? AppColors.labelForLevel(nivelRiesgo),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
