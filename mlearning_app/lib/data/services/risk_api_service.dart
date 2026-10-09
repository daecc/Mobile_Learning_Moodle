import 'dart:math';

import 'package:mlearning_early_warning/data/models/risk_model.dart';

/// Interfaz abstracta para el servicio de predicción de riesgo.
/// Permite intercambiar implementación Mock por una real (HTTP/Dio) sin tocar el ViewModel.
abstract class RiskApiService {
  /// Obtiene la predicción de riesgo para un estudiante en un curso específico.
  /// Lanza [Exception] si hay error de red o el servidor devuelve error.
  Future<PrediccionRiesgo> fetchPrediccionRiesgo({
    required String idEstudiante,
    required String idCurso,
  });
}

/// Implementación Mock del servicio de API.
/// Simula una llamada REST real con delay de 2 segundos y datos de prueba realistas.
/// En producción, reemplazar por [RiskApiServiceHttp] que use Dio/http.
class RiskApiServiceMock implements RiskApiService {
  /// Delay simulado de red (2 segundos como requisito)
  static const Duration _networkDelay = Duration(seconds: 2);

  /// Datos de prueba realistas basados en el dataset real (riesgo_academico.csv)
  /// Cada entrada simula un snapshot temporal distinto para el mismo estudiante/curso
  static final List<PrediccionRiesgo> _mockData = [
    // EST-0001, CUR-007 - Estudiante en riesgo alto sostenido (caso real del dataset)
    PrediccionRiesgo(
      idEstudiante: 'EST-0001',
      idCurso: 'CUR-007',
      fechaCorte: '2026-06-08',
      calificacionHistoricaPromedio: 7.28,
      diasInactividadConsecutivos: 8,
      probabilidadRiesgo: 0.9146,
      riesgoAcademicoConfirmado: 1,
    ),
    // EST-0001, CUR-008 - Estudiante mejorando (riesgo medio)
    PrediccionRiesgo(
      idEstudiante: 'EST-0001',
      idCurso: 'CUR-008',
      fechaCorte: '2026-06-08',
      calificacionHistoricaPromedio: 9.03,
      diasInactividadConsecutivos: 7,
      probabilidadRiesgo: 0.9594,
      riesgoAcademicoConfirmado: 1,
    ),
    // EST-0002, CUR-002 - Estudiante bueno (riesgo bajo)
    PrediccionRiesgo(
      idEstudiante: 'EST-0002',
      idCurso: 'CUR-002',
      fechaCorte: '2026-06-08',
      calificacionHistoricaPromedio: 13.66,
      diasInactividadConsecutivos: 10,
      probabilidadRiesgo: 0.5553,
      riesgoAcademicoConfirmado: 1,
    ),
    // EST-0003, CUR-002 - Estudiante excelente (riesgo bajo)
    PrediccionRiesgo(
      idEstudiante: 'EST-0003',
      idCurso: 'CUR-002',
      fechaCorte: '2026-06-08',
      calificacionHistoricaPromedio: 14.33,
      diasInactividadConsecutivos: 5,
      probabilidadRiesgo: 0.048,
      riesgoAcademicoConfirmado: 0,
    ),
    // EST-0004, CUR-004 - Caso intermedio
    PrediccionRiesgo(
      idEstudiante: 'EST-0004',
      idCurso: 'CUR-004',
      fechaCorte: '2026-06-08',
      calificacionHistoricaPromedio: 10.78,
      diasInactividadConsecutivos: 2,
      probabilidadRiesgo: 0.1,
      riesgoAcademicoConfirmado: 0,
    ),
  ];

  @override
  Future<PrediccionRiesgo> fetchPrediccionRiesgo({
    required String idEstudiante,
    required String idCurso,
  }) async {
    // Simulamos latencia de red
    await Future.delayed(_networkDelay);

    // Buscamos coincidencia exacta en datos mock
    final match = _mockData.where(
      (p) => p.idEstudiante == idEstudiante && p.idCurso == idCurso,
    ).firstOrNull;

    if (match != null) {
      return match;
    }

    // Fallback: generamos datos sintéticos coherentes si no hay match exacto
    // Esto permite probar cualquier combinación idEstudiante/idCurso
    return _generateSyntheticPrediction(idEstudiante, idCurso);
  }

  /// Genera una predicción sintética realista para IDs no presentes en mock data
  /// Basado en las distribuciones estadísticas del dataset real
  PrediccionRiesgo _generateSyntheticPrediction(String idEstudiante, String idCurso) {
    // Usamos hash del ID para generar datos determinísticos pero variados
    final seed = idEstudiante.hashCode ^ idCurso.hashCode;
    final random = _SeededRandom(seed);

    // Simulamos distribución realista del dataset:
    // - 27% riesgo confirmado (probabilidad > 0.5 aprox)
    // - Promedio calificaciones: media ~11.5, std ~3.8
    // - Días inactividad: media ~6.3, std ~2.9
    final baseProbabilidad = 0.15 + random.nextDouble() * 0.7; // 0.15 - 0.85
    final calificacion = 5.0 + random.nextGaussian() * 3.8; // ~N(11.5, 3.8)
    final diasInactividad = (3 + random.nextGaussian() * 2.9).round().clamp(0, 22);
    final riesgoConfirmado = baseProbabilidad > 0.5 ? 1 : 0;

    return PrediccionRiesgo(
      idEstudiante: idEstudiante,
      idCurso: idCurso,
      fechaCorte: DateTime.now().toIso8601String().split('T').first,
      calificacionHistoricaPromedio: calificacion.clamp(0.0, 20.0),
      diasInactividadConsecutivos: diasInactividad,
      probabilidadRiesgo: baseProbabilidad.clamp(0.0, 1.0),
      riesgoAcademicoConfirmado: riesgoConfirmado,
    );
  }
}

/// Generador pseudoaleatorio simple con semilla para datos determinísticos
/// (Evita dependencia de 'dart:math' Random en lógica de test/mock)
class _SeededRandom {
  int _seed;

  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }

  /// Distribución normal aproximada (Box-Muller simplificado)
  double nextGaussian() {
    final u1 = nextDouble();
    final u2 = nextDouble();
    return (u1 * 2 - 1) * (u2 * 2 - 1).sign * sqrt(log(u1) * -2);
  }
}