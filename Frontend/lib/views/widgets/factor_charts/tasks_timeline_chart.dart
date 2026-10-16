import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Línea de tiempo de tareas: cada segmento entregado (1) o pendiente (0).
class TasksTimelineChart extends StatelessWidget {
  final List<num> values;

  const TasksTimelineChart({super.key, this.values = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values.map((v) {
        final entregada = v >= 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: entregada ? AppColors.riskLow : AppColors.riskHighSoft,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
