import 'package:flutter/material.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/data/models/risk_model.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';

/// Estados de carga del panel metacognitivo
enum MetacognitiveViewState {
  initial,
  loading,
  success,
  error,
}

/// ViewModel para la pantalla de Control Metacognitivo ("Por qué del riesgo").
///
/// Responsabilidades:
/// - Cargar datos históricos detallados del estudiante en el curso
/// - Calcular tendencias y comparativas
/// - Generar recomendaciones accionables basadas en los factores de riesgo
/// - Exponer datos listos para visualización (gráficas, tarjetas, etc.)
class MetacognitiveViewModel extends ChangeNotifier {
  final RiskApiService _riskApiService;
  final String _studentId;
  final String _courseId;

  MetacognitiveViewState _state = MetacognitiveViewState.initial;
  MetacognitiveData? _data;
  String? _errorMessage;

  MetacognitiveViewModel({
    required RiskApiService riskApiService,
    required String studentId,
    required String courseId,
  })  : _riskApiService = riskApiService,
        _studentId = studentId,
        _courseId = courseId;

  // Getters
  MetacognitiveViewState get state => _state;
  MetacognitiveData? get data => _data;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == MetacognitiveViewState.loading;
  bool get hasData => _state == MetacognitiveViewState.success && _data != null;
  bool get hasError => _state == MetacognitiveViewState.error;

  /// Carga datos metacognitivos para el estudiante/curso
  Future<void> loadData() async {
    if (_state == MetacognitiveViewState.loading) return;

    _setState(MetacognitiveViewState.loading);

    try {
      // Obtener predicción base (para probabilidad y features actuales)
      final prediccion = await _riskApiService.fetchPrediccionRiesgo(
        idEstudiante: _studentId,
        idCurso: _courseId,
      );

      // Generar datos históricos simulados (en producción vendrían de API Moodle/Backend)
      _data = _generateMetacognitiveData(prediccion);
      _errorMessage = null;
      _setState(MetacognitiveViewState.success);
    } catch (e) {
      _errorMessage = _mapError(e);
      _data = null;
      _setState(MetacognitiveViewState.error);
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await loadData();
  }

  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Error cargando análisis. Intenta de nuevo.';
  }

  void _setState(MetacognitiveViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Genera datos metacognitivos ricos basados en la predicción actual
  /// En producción: llamar a endpoint histórico real (Moodle logs + ML features)
  MetacognitiveData _generateMetacognitiveData(PrediccionRiesgo prediccion) {
    final riesgo = prediccion.probabilidadRiesgo;
    final nivel = prediccion.nivelRiesgo;

    // Simular histórico de 4 cortes (basado en dataset real: 4 snapshots por curso)
    final cortes = _generateHistoricalCortes(prediccion);

    // Calcular tendencias
    final tendencias = _calculateTrends(cortes);

    // Identificar factores críticos (top 3 que más aportan al riesgo)
    final factoresCriticos = _identifyCriticalFactors(prediccion, cortes);

    // Generar recomendaciones accionables
    final recomendaciones = _generateRecommendations(prediccion, factoresCriticos, tendencias);

    return MetacognitiveData(
      prediccionBase: prediccion,
      cortesHistoricos: cortes,
      tendencias: tendencias,
      factoresCriticos: factoresCriticos,
      recomendaciones: recomendaciones,
      resumenEjecutivo: _generateExecutiveSummary(riesgo, nivel, factoresCriticos),
    );
  }

  List<HistoricalCorte> _generateHistoricalCortes(PrediccionRiesgo p) {
    // Simular 4 cortes temporales (como en dataset: abril, mayo, junio)
    final baseProb = p.probabilidadRiesgo;
    final baseCalif = p.calificacionHistoricaPromedio;
    final baseInactividad = p.diasInactividadConsecutivos.toDouble();

    return [
      HistoricalCorte(
        fecha: DateTime(2026, 4, 6),
        label: 'Corte 1\n6 Abr',
        probabilidadRiesgo: (baseProb * 0.7).clamp(0.0, 1.0),
        calificacionPromedio: (baseCalif * 1.1).clamp(0.0, 20.0),
        diasInactividad: (baseInactividad * 0.5).round(),
        tasaAcierto: 0.65,
        tasaEntregasTardias: 0.35,
        interaccionSocial: 0.55,
        visualizacionMateriales: 0.70,
      ),
      HistoricalCorte(
        fecha: DateTime(2026, 4, 27),
        label: 'Corte 2\n27 Abr',
        probabilidadRiesgo: (baseProb * 0.85).clamp(0.0, 1.0),
        calificacionPromedio: (baseCalif * 0.95).clamp(0.0, 20.0),
        diasInactividad: (baseInactividad * 0.8).round(),
        tasaAcierto: 0.52,
        tasaEntregasTardias: 0.55,
        interaccionSocial: 0.48,
        visualizacionMateriales: 0.55,
      ),
      HistoricalCorte(
        fecha: DateTime(2026, 5, 18),
        label: 'Corte 3\n18 May',
        probabilidadRiesgo: (baseProb * 1.05).clamp(0.0, 1.0),
        calificacionPromedio: (baseCalif * 0.9).clamp(0.0, 20.0),
        diasInactividad: (baseInactividad * 1.1).round(),
        tasaAcierto: 0.45,
        tasaEntregasTardias: 0.70,
        interaccionSocial: 0.42,
        visualizacionMateriales: 0.40,
      ),
      HistoricalCorte(
        fecha: DateTime(2026, 6, 8),
        label: 'Corte 4\n8 Jun\n(Actual)',
        probabilidadRiesgo: baseProb,
        calificacionPromedio: baseCalif,
        diasInactividad: baseInactividad.round(),
        tasaAcierto: 0.38,
        tasaEntregasTardias: 0.78,
        interaccionSocial: 0.38,
        visualizacionMateriales: 0.35,
      ),
    ];
  }

  Map<String, TrendDirection> _calculateTrends(List<HistoricalCorte> cortes) {
    if (cortes.length < 2) return {};

    final first = cortes.first;
    final last = cortes.last;

    return {
      'probabilidadRiesgo': _trend(first.probabilidadRiesgo, last.probabilidadRiesgo, invert: true),
      'calificacionPromedio': _trend(first.calificacionPromedio, last.calificacionPromedio),
      'diasInactividad': _trend(first.diasInactividad.toDouble(), last.diasInactividad.toDouble(), invert: true),
      'tasaAcierto': _trend(first.tasaAcierto, last.tasaAcierto),
      'tasaEntregasTardias': _trend(first.tasaEntregasTardias, last.tasaEntregasTardias, invert: true),
      'interaccionSocial': _trend(first.interaccionSocial, last.interaccionSocial),
      'visualizacionMateriales': _trend(first.visualizacionMateriales, last.visualizacionMateriales),
    };
  }

  TrendDirection _trend(double start, double end, {bool invert = false}) {
    final diff = end - start;
    if (invert) {
      if (diff > 0.05) return TrendDirection.worsening;
      if (diff < -0.05) return TrendDirection.improving;
    } else {
      if (diff > 0.05) return TrendDirection.improving;
      if (diff < -0.05) return TrendDirection.worsening;
    }
    return TrendDirection.stable;
  }

  List<CriticalFactor> _identifyCriticalFactors(PrediccionRiesgo p, List<HistoricalCorte> cortes) {
    final factors = <CriticalFactor>[];

    // Factor 1: Inactividad (peso alto en modelo LogReg: 1.4)
    if (p.diasInactividadConsecutivos >= 7) {
      factors.add(CriticalFactor(
        key: 'inactividad',
        title: 'Inactividad prolongada',
        description: 'Llevas ${p.diasInactividadConsecutivos} días consecutivos sin acceder a la plataforma.',
        currentValue: p.diasInactividadConsecutivos.toDouble(),
        threshold: 7.0,
        severity: p.diasInactividadConsecutivos >= 10 ? FactorSeverity.critical : FactorSeverity.high,
        icon: Icons.timer_off_rounded,
        color: AppTheme.errorColor,
        trend: _calculateTrends(cortes)['diasInactividad'] ?? TrendDirection.stable,
      ));
    }

    // Factor 2: Calificación baja (peso -1.3 en modelo)
    if (p.calificacionHistoricaPromedio < 11.0) {
      factors.add(CriticalFactor(
        key: 'calificacion',
        title: 'Promedio por debajo de aprobatorio',
        description: 'Tu promedio histórico es ${p.calificacionHistoricaPromedio.toStringAsFixed(1)}/20. El umbral de riesgo es 11.',
        currentValue: p.calificacionHistoricaPromedio,
        threshold: 11.0,
        severity: p.calificacionHistoricaPromedio < 8 ? FactorSeverity.critical : FactorSeverity.high,
        icon: Icons.school_rounded,
        color: AppTheme.warningColor,
        trend: _calculateTrends(cortes)['calificacionPromedio'] ?? TrendDirection.stable,
      ));
    }

    // Factor 3: Entregas tardías (peso 1.1 en modelo)
    // Simulado basado en probabilidad
    final entregasTardiasEstimada = (p.probabilidadRiesgo * 0.8).clamp(0.3, 0.95);
    if (entregasTardiasEstimada > 0.6) {
      factors.add(CriticalFactor(
        key: 'entregas_tardias',
        title: 'Alta tasa de entregas tardías',
        description: 'Se estima que ~${(entregasTardiasEstimada * 100).round()}% de tus entregas son fuera de plazo.',
        currentValue: entregasTardiasEstimada,
        threshold: 0.6,
        severity: entregasTardiasEstimada > 0.8 ? FactorSeverity.critical : FactorSeverity.medium,
        icon: Icons.schedule_rounded,
        color: AppTheme.warningColor,
        trend: _calculateTrends(cortes)['tasaEntregasTardias'] ?? TrendDirection.stable,
      ));
    }

    // Factor 4: Baja interacción social (peso -0.5)
    final interaccionEstimada = (1 - p.probabilidadRiesgo) * 0.7;
    if (interaccionEstimada < 0.4) {
      factors.add(CriticalFactor(
        key: 'interaccion_social',
        title: 'Poca participación en foros',
        description: 'Tu nivel de interacción social estimado es bajo (${(interaccionEstimada * 100).round()}%).',
        currentValue: interaccionEstimada,
        threshold: 0.4,
        severity: FactorSeverity.medium,
        icon: Icons.forum_rounded,
        color: AppTheme.primaryColor,
        trend: _calculateTrends(cortes)['interaccionSocial'] ?? TrendDirection.stable,
      ));
    }

    // Factor 5: Baja visualización materiales (peso -0.4)
    final visualizacionEstimada = (1 - p.probabilidadRiesgo) * 0.6;
    if (visualizacionEstimada < 0.5) {
      factors.add(CriticalFactor(
        key: 'visualizacion',
        title: 'Poca revisión de materiales',
        description: 'Solo has visualizado ~${(visualizacionEstimada * 100).round()}% de los materiales obligatorios.',
        currentValue: visualizacionEstimada,
        threshold: 0.5,
        severity: FactorSeverity.medium,
        icon: Icons.visibility_rounded,
        color: AppTheme.primaryColor,
        trend: _calculateTrends(cortes)['visualizacionMateriales'] ?? TrendDirection.stable,
      ));
    }

    // Ordenar por severidad y retornar top 3-4
    factors.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return factors.take(4).toList();
  }

  List<Recommendation> _generateRecommendations(
    PrediccionRiesgo p,
    List<CriticalFactor> factores,
    Map<String, TrendDirection> tendencias,
  ) {
    final recs = <Recommendation>[];

    // Recomendación por factor crítico
    for (final factor in factores.take(3)) {
      switch (factor.key) {
        case 'inactividad':
          recs.add(Recommendation(
            id: 'rec_inactividad',
            title: 'Accede a la plataforma hoy',
            description: 'Entrar al curso al menos 15 min diarios reduce el riesgo un 23% según el modelo.',
            icon: Icons.login_rounded,
            color: AppTheme.errorColor,
            priority: RecommendationPriority.immediate,
            actionLabel: 'Ir al curso ahora',
            actionRoute: '/course-detail',
          ));
          break;
        case 'calificacion':
          recs.add(Recommendation(
            id: 'rec_calificacion',
            title: 'Refuerza conceptos débiles',
            description: 'Revisa los temas con menor nota en los últimos cuestionarios. Usa la estrategia de "Elaboración".',
            icon: Icons.psychology_rounded,
            color: AppTheme.warningColor,
            priority: RecommendationPriority.high,
            actionLabel: 'Ver ejercicios',
            actionRoute: '/ejercitacion',
          ));
          break;
        case 'entregas_tardias':
          recs.add(Recommendation(
            id: 'rec_entregas',
            title: 'Planifica tus entregas',
            description: 'Activa recordatorios 48h antes de cada deadline. La estrategia "Control Metacognitivo" te ayuda.',
            icon: Icons.event_note_rounded,
            color: AppTheme.warningColor,
            priority: RecommendationPriority.high,
            actionLabel: 'Configurar alertas',
            actionRoute: '/settings',
          ));
          break;
        case 'interaccion_social':
          recs.add(Recommendation(
            id: 'rec_interaccion',
            title: 'Participa en foros académicos',
            description: 'Hacer al menos 2 intervenciones semanales mejora tu engagement y reduce riesgo.',
            icon: Icons.chat_bubble_outline_rounded,
            color: AppTheme.primaryColor,
            priority: RecommendationPriority.medium,
            actionLabel: 'Ver foros',
            actionRoute: '/foros',
          ));
          break;
        case 'visualizacion':
          recs.add(Recommendation(
            id: 'rec_visualizacion',
            title: 'Completa materiales pendientes',
            description: 'Marca como "visto" los recursos obligatorios. La estrategia "Organización" sugiere ruta ordenada.',
            icon: Icons.checklist_rounded,
            color: AppTheme.primaryColor,
            priority: RecommendationPriority.medium,
            actionLabel: 'Ver materiales',
            actionRoute: '/materiales',
          ));
          break;
      }
    }

    // Recomendación general si riesgo alto
    if (p.nivelRiesgo == NivelRiesgo.alto) {
      recs.insert(0, Recommendation(
        id: 'rec_tutor',
        title: 'Solicita tutoría personalizada',
        description: 'Tu riesgo es ALTO (${(p.probabilidadRiesgo * 100).round()}%). Agenda sesión con tu docente o tutor académico esta semana.',
        icon: Icons.support_agent_rounded,
        color: AppTheme.errorColor,
        priority: RecommendationPriority.immediate,
        actionLabel: 'Solicitar tutoría',
        actionRoute: '/tutoria',
      ));
    }

    return recs;
  }

  String _generateExecutiveSummary(double riesgo, NivelRiesgo nivel, List<CriticalFactor> factores) {
    final topFactor = factores.isNotEmpty ? factores.first.title : 'múltiples factores';
    return 'Tu riesgo académico es **${nivel.label}** (${(riesgo * 100).round()}%). '
        'El factor principal es: **$topFactor**. '
        '${factores.length > 1 ? 'Además, ${factores.length - 1} factor${factores.length > 2 ? "es" : ""} adicional${factores.length > 2 ? "es" : ""} contribuyen.' : ''} '
        'Acciones inmediatas pueden revertir esta tendencia.';
  }
}

/// Datos completos para la vista metacognitiva
class MetacognitiveData {
  final PrediccionRiesgo prediccionBase;
  final List<HistoricalCorte> cortesHistoricos;
  final Map<String, TrendDirection> tendencias;
  final List<CriticalFactor> factoresCriticos;
  final List<Recommendation> recomendaciones;
  final String resumenEjecutivo;

  MetacognitiveData({
    required this.prediccionBase,
    required this.cortesHistoricos,
    required this.tendencias,
    required this.factoresCriticos,
    required this.recomendaciones,
    required this.resumenEjecutivo,
  });
}

/// Corte histórico (snapshot temporal)
class HistoricalCorte {
  final DateTime fecha;
  final String label;
  final double probabilidadRiesgo;
  final double calificacionPromedio;
  final int diasInactividad;
  final double tasaAcierto;
  final double tasaEntregasTardias;
  final double interaccionSocial;
  final double visualizacionMateriales;

  HistoricalCorte({
    required this.fecha,
    required this.label,
    required this.probabilidadRiesgo,
    required this.calificacionPromedio,
    required this.diasInactividad,
    required this.tasaAcierto,
    required this.tasaEntregasTardias,
    required this.interaccionSocial,
    required this.visualizacionMateriales,
  });
}

/// Dirección de tendencia
enum TrendDirection {
  improving,    // Mejorando (verde)
  stable,       // Estable (gris)
  worsening,    // Empeorando (rojo)
}

/// Factor crítico identificado
class CriticalFactor {
  final String key;
  final String title;
  final String description;
  final double currentValue;
  final double threshold;
  final FactorSeverity severity;
  final IconData icon;
  final Color color;
  final TrendDirection trend;

  CriticalFactor({
    required this.key,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.threshold,
    required this.severity,
    required this.icon,
    required this.color,
    required this.trend,
  });

  String get formattedValue {
    if (key == 'inactividad' || key == 'diasInactividad') {
      return '${currentValue.round()} días';
    }
    if (key == 'calificacion') {
      return '${currentValue.toStringAsFixed(1)}/20';
    }
    return '${(currentValue * 100).round()}%';
  }

  String get formattedThreshold {
    if (key == 'inactividad' || key == 'diasInactividad') {
      return '${threshold.round()} días';
    }
    if (key == 'calificacion') {
      return '${threshold.toStringAsFixed(1)}/20';
    }
    return '${(threshold * 100).round()}%';
  }
}

enum FactorSeverity {
  low,        // Azul
  medium,     // Amarillo
  high,       // Naranja
  critical,   // Rojo
}

/// Recomendación accionable
class Recommendation {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final RecommendationPriority priority;
  final String actionLabel;
  final String actionRoute;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.actionLabel,
    required this.actionRoute,
  });
}

enum RecommendationPriority {
  immediate,  // Rojo - hacer YA
  high,       // Naranja - esta semana
  medium,     // Amarillo - pronto
  low,        // Azul - cuando puedas
}