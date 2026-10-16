import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Medidor semicircular (tacómetro) del nivel de riesgo.
class RiskGauge extends StatelessWidget {
  final int porcentaje;
  final String nivelRiesgo;
  final String etiqueta;
  final double size;

  const RiskGauge({
    super.key,
    required this.porcentaje,
    required this.nivelRiesgo,
    required this.etiqueta,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLevel(nivelRiesgo);
    return SizedBox(
      width: size,
      height: size * 0.62,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 0.62),
            painter: _GaugePainter(
              progress: (porcentaje.clamp(0, 100)) / 100.0,
              color: color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$porcentaje %',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.10;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      (size.height - stroke / 2) * 2,
    );
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final background = Paint()
      ..color = AppColors.neutralSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final foreground = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, background);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, foreground);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
