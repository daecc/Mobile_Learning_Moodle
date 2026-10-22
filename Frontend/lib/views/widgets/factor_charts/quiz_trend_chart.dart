import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Gráfico de tendencia de calificaciones (barras simples).
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final ratio = (v / maxValue).clamp(0.0, 1.0).toDouble();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    v.toDouble() % 1 != 0 ? v.toDouble().toStringAsFixed(1) : '${v.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 44 * ratio,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
