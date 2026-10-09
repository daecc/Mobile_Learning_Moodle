/// Modelo de datos para la predicción de riesgo académico.
/// Mapea exactamente los campos que vienen de la base de datos transaccional
/// y del modelo de ML (Regresión Logística) entrenado en Python.
class PrediccionRiesgo {
  /// Identificador único del estudiante (ej. 'EST-0001')
  final String idEstudiante;

  /// Identificador del curso (ej. 'CUR-007')
  final String idCurso;

  /// Fecha del corte temporal en formato ISO (ej. '2026-04-06')
  final String fechaCorte;

  /// Promedio histórico de calificaciones del estudiante (escala 0-20)
  final double calificacionHistoricaPromedio;

  /// Días consecutivos sin actividad en la plataforma (Moodle/App)
  final int diasInactividadConsecutivos;

  /// Probabilidad de riesgo académico devuelta por el modelo de IA (0.0 - 1.0)
  /// Ejemplo: 0.8286 = 82.86% de probabilidad de bajo rendimiento
  final double probabilidadRiesgo;

  /// Etiqueta confirmada por el modelo (1 = En riesgo, 0 = Sin riesgo)
  /// En producción este campo se usa para métricas; en la app solo usamos probabilidadRiesgo
  final int riesgoAcademicoConfirmado;

  PrediccionRiesgo({
    required this.idEstudiante,
    required this.idCurso,
    required this.fechaCorte,
    required this.calificacionHistoricaPromedio,
    required this.diasInactividadConsecutivos,
    required this.probabilidadRiesgo,
    required this.riesgoAcademicoConfirmado,
  });

  /// Factory constructor para crear una instancia desde JSON (respuesta API)
  factory PrediccionRiesgo.fromJson(Map<String, dynamic> json) {
    return PrediccionRiesgo(
      idEstudiante: json['id_estudiante'] as String,
      idCurso: json['id_curso'] as String,
      fechaCorte: json['fecha_corte'] as String,
      calificacionHistoricaPromedio: (json['calificacion_historica_promedio'] as num).toDouble(),
      diasInactividadConsecutivos: json['dias_inactividad_consecutivos'] as int,
      probabilidadRiesgo: (json['probabilidad_riesgo'] as num).toDouble(),
      riesgoAcademicoConfirmado: json['riesgo_academico_confirmado'] as int,
    );
  }

  /// Convierte la instancia a Map para serialización (ej. logging, cache local)
  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': idEstudiante,
      'id_curso': idCurso,
      'fecha_corte': fechaCorte,
      'calificacion_historica_promedio': calificacionHistoricaPromedio,
      'dias_inactividad_consecutivos': diasInactividadConsecutivos,
      'probabilidad_riesgo': probabilidadRiesgo,
      'riesgo_academico_confirmado': riesgoAcademicoConfirmado,
    };
  }

  /// Crea una copia de la instancia con campos opcionalmente actualizados
  PrediccionRiesgo copyWith({
    String? idEstudiante,
    String? idCurso,
    String? fechaCorte,
    double? calificacionHistoricaPromedio,
    int? diasInactividadConsecutivos,
    double? probabilidadRiesgo,
    int? riesgoAcademicoConfirmado,
  }) {
    return PrediccionRiesgo(
      idEstudiante: idEstudiante ?? this.idEstudiante,
      idCurso: idCurso ?? this.idCurso,
      fechaCorte: fechaCorte ?? this.fechaCorte,
      calificacionHistoricaPromedio: calificacionHistoricaPromedio ?? this.calificacionHistoricaPromedio,
      diasInactividadConsecutivos: diasInactividadConsecutivos ?? this.diasInactividadConsecutivos,
      probabilidadRiesgo: probabilidadRiesgo ?? this.probabilidadRiesgo,
      riesgoAcademicoConfirmado: riesgoAcademicoConfirmado ?? this.riesgoAcademicoConfirmado,
    );
  }

  /// Devuelve true si el estudiante está en riesgo alto (> 0.7)
  bool get esRiesgoAlto => probabilidadRiesgo > 0.7;

  /// Devuelve true si el estudiante está en riesgo medio (> 0.4)
  bool get esRiesgoMedio => probabilidadRiesgo > 0.4;

  /// Nivel de riesgo como enum legible
  NivelRiesgo get nivelRiesgo {
    if (probabilidadRiesgo > 0.7) return NivelRiesgo.alto;
    if (probabilidadRiesgo > 0.4) return NivelRiesgo.medio;
    return NivelRiesgo.bajo;
  }

  /// Color asociado al nivel de riesgo (para UI)
  /// Rojo: Alto, Amarillo: Medio, Verde: Bajo
  String get colorHex {
    switch (nivelRiesgo) {
      case NivelRiesgo.alto:
        return '#D32F2F'; // Material Red 800
      case NivelRiesgo.medio:
        return '#F9A825'; // Material Amber 700
      case NivelRiesgo.bajo:
        return '#388E3C'; // Material Green 700
    }
  }

  @override
  String toString() {
    return 'PrediccionRiesgo(idEstudiante: $idEstudiante, idCurso: $idCurso, '
        'probabilidadRiesgo: ${(probabilidadRiesgo * 100).toStringAsFixed(1)}%, '
        'nivel: $nivelRiesgo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrediccionRiesgo &&
        other.idEstudiante == idEstudiante &&
        other.idCurso == idCurso &&
        other.fechaCorte == fechaCorte;
  }

  @override
  int get hashCode {
    return idEstudiante.hashCode ^ idCurso.hashCode ^ fechaCorte.hashCode;
  }
}

/// Enum para representar los niveles de riesgo de forma type-safe
enum NivelRiesgo {
  /// Bajo riesgo (probabilidad <= 0.4) - Color verde
  bajo,

  /// Riesgo medio (0.4 < probabilidad <= 0.7) - Color amarillo/ámbar
  medio,

  /// Alto riesgo (probabilidad > 0.7) - Color rojo
  alto,
}

/// Extension para obtener labels amigables del enum
extension NivelRiesgoExtension on NivelRiesgo {
  String get label {
    switch (this) {
      case NivelRiesgo.bajo:
        return 'Bajo riesgo';
      case NivelRiesgo.medio:
        return 'Riesgo medio';
      case NivelRiesgo.alto:
        return 'Alto riesgo';
    }
  }

  String get descripcion {
    switch (this) {
      case NivelRiesgo.bajo:
        return 'Tu rendimiento es estable. ¡Sigue así!';
      case NivelRiesgo.medio:
        return 'Se detectan señales de alerta. Revisa tu progreso.';
      case NivelRiesgo.alto:
        return 'Riesgo crítico de bajo rendimiento. Busca apoyo académico.';
    }
  }
}