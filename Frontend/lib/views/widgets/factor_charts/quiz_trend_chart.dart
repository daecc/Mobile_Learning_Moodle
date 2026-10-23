import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Gráfico de tendencia de calificaciones y promedio del curso.
/// Muestra las evaluaciones individuales formateadas con decimales
/// y destaca claramente la última barra que representa el Promedio del curso.
class QuizTrendChart extends StatelessWidget {
  final List<num> values;
  final double maxValue;
  final Color color;

  const QuizTrendChart({
    super.key,
    this.values = const [],
    this.maxValue = 20,
    this.color = AppColors.brand,
  });

  String _formatGrade(num v) {
    return v.toDouble().toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAverage = values.length >= 2;

    return SizedBox(
      height: 86,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++) ...[
            // Separador sutil antes de la barra del promedio
            if (hasAverage && i == values.length - 1)
              Container(
                width: 1,
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                color: AppColors.borderOf(context),
              ),
            _buildBarItem(
              context: context,
              value: values[i],
              index: i,
              isAverage: hasAverage && (i == values.length - 1),
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarItem({
    required BuildContext context,
    required num value,
    required int index,
    required bool isAverage,
    required bool isDark,
  }) {
    final ratio = (value / maxValue).clamp(0.0, 1.0).toDouble();
    // Altura mínima para que valores bajos o cero sigan teniendo presencia visual
    final barHeight = math.max(6.0, 44.0 * ratio);

    final evalBarColor = isDark ? const Color(0xFF3B82F6) : color;
    final avgColorPrimary = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final avgColorSecondary = isDark ? const Color(0xFF0284C7) : const Color(0xFF0369A1);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Valor con decimales arriba de la barra
            Text(
              _formatGrade(value),
              style: TextStyle(
                fontSize: isAverage ? 11.5 : 11.0,
                fontWeight: isAverage ? FontWeight.w800 : FontWeight.w600,
                color: isAverage
                    ? avgColorPrimary
                    : AppColors.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 4),

            // Barra visual
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: isAverage ? null : evalBarColor,
                gradient: isAverage
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [avgColorSecondary, avgColorPrimary],
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isAverage
                    ? [
                        BoxShadow(
                          color: avgColorPrimary.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 5),

            // Etiqueta indicadora inferior
            if (isAverage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF082F49) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: avgColorPrimary.withValues(alpha: 0.8),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  'Prom.',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                  ),
                ),
              )
            else
              Text(
                'E${index + 1}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMutedOf(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
