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
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final referenceColor = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

    double maxV = 1.0;
    for (final v in values) {
      final d = v.toDouble();
      if (d > maxV) {
        maxV = d;
      }
    }

    final isComparison = values.length == 2;

    return SizedBox(
      height: 86,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final val = values[i];
          final ratio = maxV <= 0 ? 0.0 : (val.toDouble() / maxV).clamp(0.0, 1.0);

          final String label;
          final Color barColor;
          final bool isPrimary;

          if (isComparison) {
            if (i == 0) {
              label = 'Días activos';
              barColor = color;
              isPrimary = true;
            } else {
              label = 'Meta recomendada';
              barColor = referenceColor;
              isPrimary = false;
            }
          } else {
            label = (i == values.length - 1) ? 'Actual' : 'Sem ${i + 1}';
            barColor = color;
            isPrimary = i == values.length - 1;
          }

          final barWidget = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${val.toInt()}',
                style: TextStyle(
                  fontSize: isComparison ? 12.5 : 11,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? AppColors.textPrimaryOf(context) : AppColors.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                height: (isComparison ? 32 : 34) * ratio + 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(isComparison ? 6 : 4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isComparison ? 11 : 10,
                  fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                  color: isPrimary
                      ? AppColors.textPrimaryOf(context)
                      : AppColors.textMutedOf(context),
                ),
              ),
            ],
          );

          if (isComparison) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: barWidget,
                  ),
                ),
              ),
            );
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: barWidget,
            ),
          );
        }),
      ),
    );
  }
}
