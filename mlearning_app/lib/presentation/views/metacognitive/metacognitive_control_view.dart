import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/data/models/risk_model.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/metacognitive/metacognitive_viewmodel.dart';

/// Pantalla 4: Control Metacognitivo ("El por qué del riesgo").
///
/// Muestra al estudiante las estadísticas detalladas de su actividad
/// que justifican la predicción de riesgo, ayudándole a autorregularse:
/// - Resumen ejecutivo del riesgo
/// - Gráfica de evolución histórica (4 cortes)
/// - Factores críticos con severidad y tendencia
/// - Recomendaciones accionables priorizadas
class MetacognitiveControlView extends StatelessWidget {
  final String studentId;
  final String courseId;

  const MetacognitiveControlView({
    super.key,
    required this.studentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MetacognitiveViewModel>(
      create: (_) => MetacognitiveViewModel(
        riskApiService: context.read<RiskApiService>(),
        studentId: studentId,
        courseId: courseId,
      )..loadData(),
      child: _MetacognitiveViewBody(courseId: courseId),
    );
  }
}

class _MetacognitiveViewBody extends StatelessWidget {
  final String courseId;

  const _MetacognitiveViewBody({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MetacognitiveViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Control Metacognitivo'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.isLoading ? null : () => vm.refresh(),
            tooltip: 'Actualizar análisis',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, MetacognitiveViewModel vm) {
    if (vm.isLoading) return const _LoadingState();
    if (vm.hasError) {
      return _ErrorState(
        message: vm.errorMessage ?? 'Error desconocido',
        onRetry: () => vm.refresh(),
      );
    }
    if (vm.hasData) return _SuccessState(data: vm.data!);

    return const Center(child: Text('Sin datos disponibles'));
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analizando tu actividad histórica...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariantColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Procesando datos de Moodle y patrones de aprendizaje',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariantColor.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar el análisis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final MetacognitiveData data;

  const _SuccessState({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExecutiveSummaryCard(data: data),
          const SizedBox(height: 20),
          _TrendChartCard(cortes: data.cortesHistoricos),
          const SizedBox(height: 20),
          _CriticalFactorsSection(factores: data.factoresCriticos),
          const SizedBox(height: 20),
          _RecommendationsSection(recomendaciones: data.recomendaciones),
          const SizedBox(height: 20),
          _ActivityMetricsCard(data: data),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Resumen ejecutivo: riesgo + factor principal
class _ExecutiveSummaryCard extends StatelessWidget {
  final MetacognitiveData data;

  const _ExecutiveSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final nivel = data.prediccionBase.nivelRiesgo;
    final color = _nivelColor(nivel);
    final topFactor =
        data.factoresCriticos.isNotEmpty ? data.factoresCriticos.first : null;

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_nivelIcon(nivel), color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen Ejecutivo',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.onSurfaceVariantColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        nivel.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(data.prediccionBase.probabilidadRiesgo * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topFactor != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.outlineColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(topFactor.icon, color: topFactor.color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Factor principal',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.onSurfaceVariantColor,
                                ),
                          ),
                          Text(
                            topFactor.title,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      topFactor.formattedValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: topFactor.color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Tienes ${data.factoresCriticos.length} factor${data.factoresCriticos.length > 1 ? "es" : ""} '
              'que contribuyen${data.factoresCriticos.length > 1 ? "en" : ""} a este riesgo. '
              'Revisa cada uno y aplica las recomendaciones para mejorar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _nivelColor(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.alto:
        return AppTheme.errorColor;
      case NivelRiesgo.medio:
        return AppTheme.warningColor;
      case NivelRiesgo.bajo:
        return AppTheme.successColor;
    }
  }

  IconData _nivelIcon(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.alto:
        return Icons.error_rounded;
      case NivelRiesgo.medio:
        return Icons.warning_amber_rounded;
      case NivelRiesgo.bajo:
        return Icons.check_circle_rounded;
    }
  }
}

/// Gráfica de evolución: probabilidad de riesgo en 4 cortes
class _TrendChartCard extends StatelessWidget {
  final List<HistoricalCorte> cortes;

  const _TrendChartCard({required this.cortes});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded,
                    color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Evolución del Riesgo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Probabilidad de riesgo en los últimos 4 cortes temporales',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: _CustomLineChart(cortes: cortes),
            ),
            const SizedBox(height: 12),
            // Leyenda de cortes debajo de la gráfica
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: cortes.map((c) {
                final isActual = c.label.contains('Actual');
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isActual
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.label.replaceAll('\n', ' '),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isActual ? FontWeight.w700 : FontWeight.w400,
                          color: isActual
                              ? AppTheme.primaryColor
                              : AppTheme.onSurfaceVariantColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gráfica de línea personalizada sin dependencias externas
class _CustomLineChart extends StatelessWidget {
  final List<HistoricalCorte> cortes;

  const _CustomLineChart({required this.cortes});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        const padding = EdgeInsets.only(left: 36, right: 12, top: 12, bottom: 24);
        final chartW = width - padding.left - padding.right;
        final chartH = height - padding.top - padding.bottom;

        return CustomPaint(
          size: Size(width, height),
          painter: _LineChartPainter(
            cortes: cortes,
            padding: padding,
            chartWidth: chartW,
            chartHeight: chartH,
            gridColor: AppTheme.outlineColor.withValues(alpha: 0.2),
            lineColor: AppTheme.primaryColor,
            labelColor: AppTheme.onSurfaceVariantColor,
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<HistoricalCorte> cortes;
  final EdgeInsets padding;
  final double chartWidth;
  final double chartHeight;
  final Color gridColor;
  final Color lineColor;
  final Color labelColor;

  _LineChartPainter({
    required this.cortes,
    required this.padding,
    required this.chartWidth,
    required this.chartHeight,
    required this.gridColor,
    required this.lineColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cortes.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final labelStyle = TextStyle(fontSize: 9, color: labelColor);

    // Grid horizontal + labels Y
    for (int i = 0; i <= 4; i++) {
      final y = padding.top + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(padding.left + chartWidth, y),
        gridPaint,
      );
      final value = 100 - i * 25;
      final tp = TextPainter(
        text: TextSpan(text: '$value%', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - 6));
    }

    // Calcular puntos X e Y
    final points = <Offset>[];
    for (int i = 0; i < cortes.length; i++) {
      final x = padding.left + (chartWidth / (cortes.length - 1)) * i;
      final probPct = cortes[i].probabilidadRiesgo * 100;
      final y = padding.top + chartHeight - (probPct / 100) * chartHeight;
      points.add(Offset(x, y));
    }

    // Área bajo la línea (gradiente)
    final areaPath = Path()
      ..moveTo(points.first.dx, padding.top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      areaPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy,
          points[i].dx, points[i].dy);
    }
    areaPath
      ..lineTo(points.last.dx, padding.top + chartHeight)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(
          Rect.fromLTWH(padding.left, padding.top, chartWidth, chartHeight));
    canvas.drawPath(areaPath, areaPaint);

    // Línea principal (curva suave)
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy,
          points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Puntos en cada corte
    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;

      // Borde blanco del punto
      canvas.drawCircle(
          points[i],
          isLast ? 6 : 4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..strokeWidth = 2);

      // Punto central
      canvas.drawCircle(
          points[i],
          isLast ? 5 : 3,
          Paint()
            ..color = isLast ? lineColor : lineColor.withValues(alpha: 0.6)
            ..style = PaintingStyle.fill);

      // Valor encima del punto
      final probText = '${(cortes[i].probabilidadRiesgo * 100).round()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: probText,
          style: TextStyle(
            fontSize: isLast ? 11 : 10,
            fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            color: isLast ? lineColor : labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[i].dx - tp.width / 2, points[i].dy - tp.height - 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.cortes != cortes;
}

/// Sección de factores críticos
class _CriticalFactorsSection extends StatelessWidget {
  final List<CriticalFactor> factores;

  const _CriticalFactorsSection({required this.factores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.priority_high_rounded,
                color: AppTheme.errorColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Factores Críticos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${factores.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Estos factores son los principales contribuyentes a tu riesgo académico',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariantColor,
              ),
        ),
        const SizedBox(height: 12),
        ...factores.map((f) => _FactorDetailCard(factor: f)),
      ],
    );
  }
}

class _FactorDetailCard extends StatelessWidget {
  final CriticalFactor factor;

  const _FactorDetailCard({required this.factor});

  @override
  Widget build(BuildContext context) {
    final severityConfig = _getSeverityConfig(factor.severity);

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: severityConfig.color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityConfig.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(factor.icon, color: factor.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factor.title,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceColor,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              severityConfig.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          severityConfig.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: severityConfig.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _TrendBadge(trend: factor.trend),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              factor.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 10),
            // Barra de valor vs umbral
            _ThresholdBar(
              currentValue: factor.currentValue,
              threshold: factor.threshold,
              valueLabel: factor.formattedValue,
              thresholdLabel: 'Umbral: ${factor.formattedThreshold}',
              color: factor.color,
              maxValue: factor.key == 'calificacion' ? 20.0 : 1.0,
            ),
          ],
        ),
      ),
    );
  }

  ({Color color, String label}) _getSeverityConfig(FactorSeverity s) {
    switch (s) {
      case FactorSeverity.critical:
        return (color: AppTheme.errorColor, label: 'CRÍTICO');
      case FactorSeverity.high:
        return (color: const Color(0xFFFF6D00), label: 'ALTO');
      case FactorSeverity.medium:
        return (color: AppTheme.warningColor, label: 'MEDIO');
      case FactorSeverity.low:
        return (color: AppTheme.primaryColor, label: 'BAJO');
    }
  }
}

/// Badge de tendencia (mejorando/estable/empeorando)
class _TrendBadge extends StatelessWidget {
  final TrendDirection trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (trend) {
      TrendDirection.improving =>
        (Icons.trending_up_rounded, AppTheme.successColor, 'Mejorando'),
      TrendDirection.stable =>
        (Icons.trending_flat_rounded, AppTheme.onSurfaceVariantColor, 'Estable'),
      TrendDirection.worsening =>
        (Icons.trending_down_rounded, AppTheme.errorColor, 'Empeorando'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra visual valor vs umbral
class _ThresholdBar extends StatelessWidget {
  final double currentValue;
  final double threshold;
  final String valueLabel;
  final String thresholdLabel;
  final Color color;
  final double maxValue;

  const _ThresholdBar({
    required this.currentValue,
    required this.threshold,
    required this.valueLabel,
    required this.thresholdLabel,
    required this.color,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final currentPct = (currentValue / maxValue).clamp(0.0, 1.0);
    final thresholdPct = (threshold / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              valueLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              thresholdLabel,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.onSurfaceVariantColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Fondo
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Llenado
                FractionallySizedBox(
                  widthFactor: currentPct,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.6), color],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Marcador de umbral
                Positioned(
                  left: (thresholdPct * constraints.maxWidth) - 1,
                  top: -2,
                  child: Container(
                    width: 2,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.onSurfaceColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Sección de recomendaciones accionables
class _RecommendationsSection extends StatelessWidget {
  final List<Recommendation> recomendaciones;

  const _RecommendationsSection({required this.recomendaciones});

  @override
  Widget build(BuildContext context) {
    if (recomendaciones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                color: AppTheme.warningColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Recomendaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Acciones específicas para reducir tu riesgo académico',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariantColor,
              ),
        ),
        const SizedBox(height: 12),
        ...recomendaciones.map((r) => _RecommendationCard(recommendation: r)),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final priorityConfig = _getPriorityConfig(recommendation.priority);

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: recommendation.color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: recommendation.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(recommendation.icon, color: recommendation.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recommendation.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  priorityConfig.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              priorityConfig.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: priorityConfig.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recommendation.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariantColor,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Rutas aún no implementadas - mostrar SnackBar informativo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '"${recommendation.actionLabel}" estará disponible pronto',
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_rounded,
                    size: 16, color: recommendation.color),
                label: Text(recommendation.actionLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: recommendation.color,
                  side: BorderSide(
                    color: recommendation.color.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color color, String label}) _getPriorityConfig(RecommendationPriority p) {
    switch (p) {
      case RecommendationPriority.immediate:
        return (color: AppTheme.errorColor, label: 'AHORA');
      case RecommendationPriority.high:
        return (color: const Color(0xFFFF6D00), label: 'ESTA SEMANA');
      case RecommendationPriority.medium:
        return (color: AppTheme.warningColor, label: 'PRONTO');
      case RecommendationPriority.low:
        return (color: AppTheme.primaryColor, label: 'OPORTUNO');
    }
  }
}

/// Tarjeta de métricas de actividad (detalles de los 4 cortes)
class _ActivityMetricsCard extends StatelessWidget {
  final MetacognitiveData data;

  const _ActivityMetricsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final actual = data.cortesHistoricos.last;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined,
                    color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Métricas de Actividad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Datos transaccionales del último corte (Moodle)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              icon: Icons.task_alt_rounded,
              label: 'Tasa de acierto en evaluaciones',
              value: '${(actual.tasaAcierto * 100).round()}%',
              color: actual.tasaAcierto >= 0.5
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
            _MetricRow(
              icon: Icons.schedule_rounded,
              label: 'Entregas fuera de plazo',
              value: '${(actual.tasaEntregasTardias * 100).round()}%',
              color: actual.tasaEntregasTardias <= 0.4
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
            _MetricRow(
              icon: Icons.forum_rounded,
              label: 'Interacción social (foros)',
              value: '${(actual.interaccionSocial * 100).round()}%',
              color: actual.interaccionSocial >= 0.4
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
            ),
            _MetricRow(
              icon: Icons.visibility_rounded,
              label: 'Materiales visualizados',
              value: '${(actual.visualizacionMateriales * 100).round()}%',
              color: actual.visualizacionMateriales >= 0.5
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
            ),
            _MetricRow(
              icon: Icons.timer_off_rounded,
              label: 'Días inactividad consecutiva',
              value: '${actual.diasInactividad} días',
              color: actual.diasInactividad <= 3
                  ? AppTheme.successColor
                  : actual.diasInactividad <= 7
                      ? AppTheme.warningColor
                      : AppTheme.errorColor,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppTheme.outlineColor.withValues(alpha: 0.15),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
