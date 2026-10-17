/// Métrica metacognitiva mostrada como tarjeta explicativa.
class MetacognitiveStat {
  final String clave;
  final String titulo;
  final String valor;
  final String? unidad;
  final String estado; // ok | alerta | critico
  final String descripcion;

  const MetacognitiveStat({
    required this.clave,
    required this.titulo,
    required this.valor,
    this.unidad,
    required this.estado,
    required this.descripcion,
  });

  factory MetacognitiveStat.fromJson(Map<String, dynamic> json) {
    return MetacognitiveStat(
      clave: json['clave'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      valor: json['valor'] as String? ?? '',
      unidad: json['unidad'] as String?,
      estado: json['estado'] as String? ?? 'ok',
      descripcion: json['descripcion'] as String? ?? '',
    );
  }
}

/// Factor individual que explica la estimación de riesgo.
class RiskFactor {
  final String clave;
  final String titulo;
  final String subtitulo;
  final String impacto; // aumenta | reduce
  final int influencia;
  final String? chartType; // day_circles | quiz_trend | tasks_timeline | weekly_logins
  final List<num> chartValues;

  const RiskFactor({
    required this.clave,
    required this.titulo,
    required this.subtitulo,
    required this.impacto,
    this.influencia = 1,
    this.chartType,
    this.chartValues = const [],
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      clave: json['clave'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      subtitulo: json['subtitulo'] as String? ?? '',
      impacto: json['impacto'] as String? ?? 'reduce',
      influencia: (json['influencia'] as num?)?.toInt() ?? 1,
      chartType: json['chartType'] as String?,
      chartValues: ((json['chartValues'] as List<dynamic>?) ?? const [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  bool get sumaRiesgo => impacto == 'aumenta';
}

/// Conjunto de factores explicativos (pantalla "¿Por qué este resultado?").
class FactoresBundle {
  final String periodo;
  final int sumanRiesgo;
  final int jueganFavor;
  final List<RiskFactor> riesgos;
  final List<RiskFactor> favorables;
  final List<String> reflexionOpciones;

  const FactoresBundle({
    required this.periodo,
    required this.sumanRiesgo,
    required this.jueganFavor,
    required this.riesgos,
    required this.favorables,
    this.reflexionOpciones = const [],
  });

  factory FactoresBundle.fromJson(Map<String, dynamic> json) {
    return FactoresBundle(
      periodo: json['periodo'] as String? ?? 'últimas semanas',
      sumanRiesgo: (json['sumanRiesgo'] as num?)?.toInt() ?? 0,
      jueganFavor: (json['jueganFavor'] as num?)?.toInt() ?? 0,
      riesgos: ((json['riesgos'] as List<dynamic>?) ?? const [])
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      favorables: ((json['favorables'] as List<dynamic>?) ?? const [])
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      reflexionOpciones: ((json['reflexionOpciones'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Detalle completo del riesgo de un curso.
class RiskDetailResponse {
  final String idEstudiante;
  final String idCurso;
  final String nombreCurso;
  final String codigoCurso;
  final String fechaCorte;
  final double probabilidadRiesgo;
  final int porcentajeRiesgo;
  final String nivelRiesgo; // BAJO | MODERADO | CRITICO | SIN_ESTIMACION
  final String alertaTitulo;
  final String alertaMensaje;
  final String accionRecomendada;
  final List<MetacognitiveStat> metricas;
  final int rangoMin;
  final int rangoMax;
  final String? pasoTitulo;
  final String? pasoSubtitulo;
  final String? pasoTipo;
  final String? actualizadoLabel;
  final String? siguientePasoDetalle;
  final String? mensajeSinEstimacion;
  final String? progresoSemana;
  final int progresoActual;
  final int progresoTotal;
  final FactoresBundle? factores;

  const RiskDetailResponse({
    required this.idEstudiante,
    required this.idCurso,
    required this.nombreCurso,
    required this.codigoCurso,
    required this.fechaCorte,
    required this.probabilidadRiesgo,
    required this.porcentajeRiesgo,
    required this.nivelRiesgo,
    required this.alertaTitulo,
    required this.alertaMensaje,
    required this.accionRecomendada,
    this.metricas = const [],
    this.rangoMin = 0,
    this.rangoMax = 0,
    this.pasoTitulo,
    this.pasoSubtitulo,
    this.pasoTipo,
    this.actualizadoLabel,
    this.siguientePasoDetalle,
    this.mensajeSinEstimacion,
    this.progresoSemana,
    this.progresoActual = 0,
    this.progresoTotal = 0,
    this.factores,
  });

  bool get esSinEstimacion =>
      nivelRiesgo == 'SIN_ESTIMACION' || porcentajeRiesgo < 0;

  String get cleanNombreCurso {
    if (nombreCurso.contains(':')) {
      final parts = nombreCurso.split(':');
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        return parts.sublist(1).join(':').trim();
      }
    }
    return nombreCurso;
  }

  factory RiskDetailResponse.fromJson(Map<String, dynamic> json) {
    return RiskDetailResponse(
      idEstudiante: json['id_estudiante'] as String? ?? '',
      idCurso: json['id_curso'] as String? ?? '',
      nombreCurso: json['nombre_curso'] as String? ?? '',
      codigoCurso: json['codigo_curso'] as String? ?? '',
      fechaCorte: json['fecha_corte'] as String? ?? '',
      probabilidadRiesgo:
          (json['probabilidad_riesgo'] as num?)?.toDouble() ?? 0.0,
      porcentajeRiesgo: (json['porcentaje_riesgo'] as num?)?.toInt() ?? 0,
      nivelRiesgo: json['nivel_riesgo'] as String? ?? 'BAJO',
      alertaTitulo: json['alerta_titulo'] as String? ?? '',
      alertaMensaje: json['alerta_mensaje'] as String? ?? '',
      accionRecomendada: json['accion_recomendada'] as String? ?? '',
      metricas: ((json['metricas'] as List<dynamic>?) ?? const [])
          .map((e) => MetacognitiveStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      rangoMin: (json['rango_min'] as num?)?.toInt() ?? 0,
      rangoMax: (json['rango_max'] as num?)?.toInt() ?? 0,
      pasoTitulo: json['paso_titulo'] as String?,
      pasoSubtitulo: json['paso_subtitulo'] as String?,
      pasoTipo: json['paso_tipo'] as String?,
      factores: json['factores'] != null
          ? FactoresBundle.fromJson(json['factores'] as Map<String, dynamic>)
          : null,
    );
  }
}
