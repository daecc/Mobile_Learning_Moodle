import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Gráfico de círculos: un punto por día con o sin actividad.
class DayCirclesChart extends StatelessWidget {
  final List<num> values;
  final Color color;

  const DayCirclesChart({
    super.key,
    this.values = const [],
    this.color = AppColors.riskHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(values.length, (i) {
        final active = values[i] >= 1;
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? color
                : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : AppColors.neutralSoft),
            border: Border.all(
              color: active ? color : AppColors.borderOf(context),
            ),
          ),
        );
      }),
    );
  }
}
