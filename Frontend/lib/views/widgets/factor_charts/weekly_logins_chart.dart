import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Gráfico de accesos semanales (barras verticales).
class WeeklyLoginsChart extends StatelessWidget {
  final List<num> values;
  final Color color;

  const WeeklyLoginsChart({
    super.key,
    this.values = const [],
    this.color = AppColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final ratio = maxV == 0 ? 0.0 : (values[i] / maxV).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[i]}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 36 * ratio + 2,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
