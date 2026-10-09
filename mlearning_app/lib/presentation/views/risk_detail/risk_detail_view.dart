import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/risk_viewmodel.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';
import 'package:mlearning_early_warning/data/models/risk_model.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/presentation/views/metacognitive/metacognitive_control_view.dart';

/// Pantalla principal: Dashboard de Riesgo Académico.
///
/// Muestra la predicción del modelo de IA (Regresión Logística) con:
/// - Gauge circular tipo velocímetro con semáforo (Verde/Amarillo/Rojo)
/// - Tarjetas explicativas con las variables clave (calificación, inactividad)
/// - Estados: loading, error, success
///
/// Arquitectura MVVM estricta:
/// - La Vista **solo** se suscribe al ViewModel via Provider
/// - **Nunca** llama directamente a servicios ni contiene lógica de negocio
/// - **Solo** renderiza y delega eventos de usuario al ViewModel
class RiskDetailView extends StatelessWidget {
  /// Identificador del curso a analizar (opcional, usa default del mock si null)
  final String? courseId;

  /// Nombre legible del curso (para header)
  final String? courseName;

  const RiskDetailView({
    super.key,
    this.courseId,
    this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios del ViewModel via Provider
    return ChangeNotifierProvider<RiskViewModel>(
      create: (_) => RiskViewModel(
        apiService: context.read<RiskApiService>(),
        cursoId: courseId ?? 'CUR-007',
      )..cargarPrediccion(),
      child: _RiskDetailViewBody(courseName: courseName),
    );
  }
}

/// Cuerpo principal de la vista para separar lógica de Provider
class _RiskDetailViewBody extends StatelessWidget {
  final String? courseName;

  const _RiskDetailViewBody({this.courseName});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RiskViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context, vm),
      body: _buildBody(context, vm),
    );
  }

  /// AppBar con título, indicador de curso y botón de refresh
  PreferredSizeWidget _buildAppBar(BuildContext context, RiskViewModel vm) {
    return AppBar(
      title: Text(courseName ?? 'Alerta Temprana'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.onSurfaceColor,
      actions: [
        // Botón refresh - delega al ViewModel
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: vm.isLoading ? null : () => vm.reintentar(),
          tooltip: 'Actualizar predicción',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Cuerpo principal con estado reactivo
  Widget _buildBody(BuildContext context, RiskViewModel vm) {
    // Estados mutuamente excluyentes
    if (vm.isLoading) return const _LoadingState();
    if (vm.hasError) return _ErrorState(message: vm.errorMessage!, onRetry: vm.reintentar);
    if (vm.hasData) return _SuccessState(prediccion: vm.prediccion!, vm: vm);

    // Fallback (no debería ocurrir)
    return const _EmptyState();
  }
}

/// Estado de carga: indicador centrado con mensaje
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
            'Analizando tu rendimiento académico...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariantColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Consultando modelo de IA (Regresión Logística)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariantColor.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

/// Estado de error: mensaje + botón reintentar
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
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la predicción',
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
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.onPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío (fallback)
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Selecciona un curso para ver tu riesgo',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariantColor,
            ),
      ),
    );
  }
}

/// Estado éxito: Gauge principal + tarjetas explicativas
class _SuccessState extends StatelessWidget {
  final PrediccionRiesgo prediccion;
  final RiskViewModel vm;

  const _SuccessState({required this.prediccion, required this.vm});

  @override
  Widget build(BuildContext context) {
    final colorRiesgo = _parseColor(prediccion.colorHex);
    final nivel = prediccion.nivelRiesgo;

    return RefreshIndicator(
      onRefresh: vm.reintentar,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con info del curso
            _CourseHeader(
              idEstudiante: prediccion.idEstudiante,
              idCurso: prediccion.idCurso,
              fechaCorte: vm.fechaCorteFormateada,
            ),
            const SizedBox(height: 24),

            // Gauge circular principal (el "velocímetro")
            _RiskGauge(
              probabilidad: prediccion.probabilidadRiesgo,
              color: colorRiesgo,
              nivel: nivel,
              label: vm.riesgoPorcentaje,
            ),
            const SizedBox(height: 16),

            // Label y descripción del nivel
            _RiskLevelBadge(nivel: nivel),
            const SizedBox(height: 24),

            // Tarjetas explicativas ("Por qué")
            _WhyCards(
              calificacion: vm.calificacionFormateada,
              inactividad: vm.inactividadFormateada,
              colorRiesgo: colorRiesgo,
            ),
            const SizedBox(height: 16),

            // Botón: Análisis Metacognitivo completo (Pantalla 4)
            _MetacognitiveButton(
              studentId: prediccion.idEstudiante,
              courseId: prediccion.idCurso,
            ),
            const SizedBox(height: 24),

            // Disclaimer / nota metodológica
            _DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Header con identificación del estudiante y curso
class _CourseHeader extends StatelessWidget {
  final String idEstudiante;
  final String idCurso;
  final String fechaCorte;

  const _CourseHeader({
    required this.idEstudiante,
    required this.idCurso,
    required this.fechaCorte,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estudiante: $idEstudiante',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Curso: $idCurso',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariantColor,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Corte: $fechaCorte',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

/// Gauge circular tipo velocímetro (Syncfusion)
class _RiskGauge extends StatelessWidget {
  final double probabilidad;
  final Color color;
  final NivelRiesgo nivel;
  final String label;

  const _RiskGauge({
    required this.probabilidad,
    required this.color,
    required this.nivel,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 1500,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            startAngle: 180,
            endAngle: 0,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.15,
              cornerStyle: CornerStyle.bothCurve,
              color: AppTheme.outlineColor.withValues(alpha: 0.2),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            // Rangos de color (semáforo)
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: 40,
                color: AppTheme.successColor,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: 40,
                endValue: 70,
                color: AppTheme.warningColor,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: 70,
                endValue: 100,
                color: AppTheme.errorColor,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
            ],
            // Puntero principal (aguja)
            pointers: <GaugePointer>[
              NeedlePointer(
                value: probabilidad * 100,
                enableAnimation: true,
                animationDuration: 1200,
                animationType: AnimationType.easeOutBack,
                needleLength: 0.6,
                needleStartWidth: 1,
                needleEndWidth: 4,
                knobStyle: KnobStyle(
                  knobRadius: 0.08,
                  color: color,
                  borderWidth: 3,
                  borderColor: Colors.white,
                ),
                tailStyle: TailStyle(
                  length: 0.15,
                  color: color,
                  width: 4,
                ),
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
              ),
              // Puntero de rango (barra de progreso interna)
              RangePointer(
                value: probabilidad * 100,
                enableAnimation: true,
                animationDuration: 1000,
                width: 0.12,
                color: color,
                cornerStyle: CornerStyle.bothCurve,
              ),
              // Texto central con porcentaje
              WidgetPointer(
                value: probabilidad * 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Probabilidad de riesgo',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.onSurfaceVariantColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            // Anotaciones para labels de rango (bajo/medio/alto)
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 180,
                positionFactor: 1.15,
                widget: _RangeLabel(
                  label: 'BAJO',
                  color: AppTheme.successColor,
                  start: 0,
                  end: 40,
                ),
              ),
              GaugeAnnotation(
                angle: 180,
                positionFactor: 1.35,
                widget: _RangeLabel(
                  label: 'MEDIO',
                  color: AppTheme.warningColor,
                  start: 40,
                  end: 70,
                ),
              ),
              GaugeAnnotation(
                angle: 180,
                positionFactor: 1.15,
                widget: _RangeLabel(
                  label: 'ALTO',
                  color: AppTheme.errorColor,
                  start: 70,
                  end: 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Label pequeño para los rangos del gauge
class _RangeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final int start;
  final int end;

  const _RangeLabel({
    required this.label,
    required this.color,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label ($start-$end%)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Badge con el nivel de riesgo y descripción
class _RiskLevelBadge extends StatelessWidget {
  final NivelRiesgo nivel;

  const _RiskLevelBadge({required this.nivel});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(nivel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, color: config.color, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nivel.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: config.color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  nivel.descripcion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: config.color.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _RiskConfig _getConfig(NivelRiesgo nivel) => switch (nivel) {
      NivelRiesgo.alto => _RiskConfig(
          color: AppTheme.errorColor,
          icon: Icons.error_rounded,
        ),
      NivelRiesgo.medio => _RiskConfig(
          color: AppTheme.warningColor,
          icon: Icons.warning_amber_rounded,
        ),
      NivelRiesgo.bajo => _RiskConfig(
          color: AppTheme.successColor,
          icon: Icons.check_circle_rounded,
        ),
    };
}

class _RiskConfig {
  final Color color;
  final IconData icon;
  _RiskConfig({required this.color, required this.icon});
}

/// Tarjetas explicativas: "¿Por qué este riesgo?"
class _WhyCards extends StatelessWidget {
  final String calificacion;
  final String inactividad;
  final Color colorRiesgo;

  const _WhyCards({
    required this.calificacion,
    required this.inactividad,
    required this.colorRiesgo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Factores clave',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FactorCard(
                icon: Icons.school_rounded,
                title: 'Promedio histórico',
                value: calificacion,
                subtitle: 'Calificaciones (0-20)',
                iconColor: AppTheme.primaryColor,
                trend: _getCalificacionTrend(calificacion),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FactorCard(
                icon: Icons.timer_off_rounded,
                title: 'Inactividad',
                value: inactividad,
                subtitle: 'Días sin acceso',
                iconColor: AppTheme.warningColor,
                trend: _getInactividadTrend(inactividad),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Determina tendencia visual para calificación
  String? _getCalificacionTrend(String calif) {
    final valor = double.tryParse(calif.split(' ').first) ?? 0;
    if (valor >= 14) return 'Excelente';
    if (valor >= 11) return 'Aprobatorio';
    if (valor >= 8) return 'En riesgo';
    return 'Crítico';
  }

  /// Determina tendencia visual para inactividad
  String? _getInactividadTrend(String inact) {
    final valor = int.tryParse(inact.split(' ').first) ?? 0;
    if (valor <= 2) return 'Activo';
    if (valor <= 5) return 'Leve';
    if (valor <= 10) return 'Preocupante';
    return 'Crítico';
  }
}

/// Tarjeta individual de factor
class _FactorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color iconColor;
  final String? trend;

  const _FactorCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconColor,
    this.trend,
  });

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTrendColor(trend!).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getTrendColor(trend!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantColor.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Excelente':
      case 'Activo':
        return AppTheme.successColor;
      case 'Aprobatorio':
      case 'Leve':
        return AppTheme.primaryColor;
      case 'En riesgo':
      case 'Preocupante':
        return AppTheme.warningColor;
      case 'Crítico':
        return AppTheme.errorColor;
      default:
        return AppTheme.onSurfaceVariantColor;
    }
  }
}

/// Tarjeta de disclaimer metodológico
class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre esta predicción',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Este indicador se genera con un modelo de Regresión Logística '
                    'entrenado con datos históricos de interacción en Moodle '
                    '(calificaciones, inactividad, entregas, participación). '
                    'La predicción es probabilística, no determinística.',
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
      ),
    );
  }
}

/// Botón para navegar al Panel de Control Metacognitivo (Pantalla 4)
class _MetacognitiveButton extends StatelessWidget {
  final String studentId;
  final String courseId;

  const _MetacognitiveButton({
    required this.studentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MetacognitiveControlView(
                studentId: studentId,
                courseId: courseId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Por qué este riesgo?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurfaceColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ver análisis metacognitivo completo: tendencias, '
                      'factores críticos y recomendaciones personalizadas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariantColor,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}