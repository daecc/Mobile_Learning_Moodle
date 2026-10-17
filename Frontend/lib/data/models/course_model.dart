/// Resumen de distribución de riesgo usado en la cabecera de "Mis cursos".
class RiskDistributionSummary {
  final int bajo;
  final int moderado;
  final int critico;
  final int sinEstimacion;

  const RiskDistributionSummary({
    this.bajo = 0,
    this.moderado = 0,
    this.critico = 0,
    this.sinEstimacion = 0,
  });

  factory RiskDistributionSummary.fromJson(Map<String, dynamic> json) {
    return RiskDistributionSummary(
      bajo: (json['bajo'] as num?)?.toInt() ?? 0,
      moderado: (json['moderado'] as num?)?.toInt() ?? 0,
      critico: (json['critico'] as num?)?.toInt() ?? 0,
      sinEstimacion: (json['sin_estimacion'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Tarjeta de curso con su última estimación de riesgo.
class CourseRiskSummary {
  final String idCurso;
  final String nombreCurso;
  final String codigoCurso;
  final int creditos;
  final String docente;
  final double probabilidadRiesgo;
  final int porcentajeRiesgo;
  final String nivelRiesgo; // BAJO | MODERADO | CRITICO | SIN_ESTIMACION
  final String? fechaEstimacion;

  const CourseRiskSummary({
    required this.idCurso,
    required this.nombreCurso,
    required this.codigoCurso,
    required this.creditos,
    required this.docente,
    required this.probabilidadRiesgo,
    required this.porcentajeRiesgo,
    required this.nivelRiesgo,
    this.fechaEstimacion,
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

  factory CourseRiskSummary.fromJson(Map<String, dynamic> json) {
    return CourseRiskSummary(
      idCurso: json['id_curso'] as String? ?? '',
      nombreCurso: json['nombre_curso'] as String? ?? '',
      codigoCurso: json['codigo_curso'] as String? ?? 'CUR',
      creditos: (json['creditos'] as num?)?.toInt() ?? 3,
      docente: json['docente'] as String? ?? 'Docente Asignado',
      probabilidadRiesgo:
          (json['probabilidad_riesgo'] as num?)?.toDouble() ?? 0.0,
      porcentajeRiesgo: (json['porcentaje_riesgo'] as num?)?.toInt() ?? 0,
      nivelRiesgo: json['nivel_riesgo'] as String? ?? 'BAJO',
      fechaEstimacion: json['fecha_estimacion'] as String?,
    );
  }
}

/// Respuesta completa del endpoint `/api/estudiantes/{id}/cursos`.
class StudentCoursesResponse {
  final String idEstudiante;
  final String nombreEstudiante;
  final int totalCursos;
  final RiskDistributionSummary resumenRiesgo;
  final List<CourseRiskSummary> cursos;

  const StudentCoursesResponse({
    required this.idEstudiante,
    required this.nombreEstudiante,
    required this.totalCursos,
    required this.resumenRiesgo,
    required this.cursos,
  });

  factory StudentCoursesResponse.fromJson(Map<String, dynamic> json) {
    return StudentCoursesResponse(
      idEstudiante: json['id_estudiante'] as String? ?? '',
      nombreEstudiante: json['nombre_estudiante'] as String? ?? 'Estudiante',
      totalCursos: (json['total_cursos'] as num?)?.toInt() ?? 0,
      resumenRiesgo: RiskDistributionSummary.fromJson(
        (json['resumen_riesgo'] as Map<String, dynamic>?) ?? const {},
      ),
      cursos: ((json['cursos'] as List<dynamic>?) ?? const [])
          .map((e) => CourseRiskSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
