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

  String get cleanNombreCurso => formatCourseTitle(nombreCurso);

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

const Map<String, String> _knownCourseAccents = {
  'CONSTRUCCION': 'Construcción',
  'Construccion': 'Construcción',
  'MOVIL': 'Móvil',
  'Movil': 'Móvil',
  'GARANTIA': 'Garantía',
  'Garantia': 'Garantía',
  'GESTION': 'Gestión',
  'Gestion': 'Gestión',
  'ANALITICA': 'Analítica',
  'Analitica': 'Analítica',
  'DISENO': 'Diseño',
  'Diseno': 'Diseño',
  'INGENIERIA': 'Ingeniería',
  'Ingenieria': 'Ingeniería',
  'METODOLOGIA': 'Metodología',
  'Metodologia': 'Metodología',
  'PROGRAMACION': 'Programación',
  'Programacion': 'Programación',
  'COMPUTACION': 'Computación',
  'Computacion': 'Computación',
  'ESTADISTICA': 'Estadística',
  'Estadistica': 'Estadística',
  'ADMINISTRACION': 'Administración',
  'Administracion': 'Administración',
  'FISICA': 'Física',
  'Fisica': 'Física',
  'QUIMICA': 'Química',
  'Quimica': 'Química',
  'LOGICA': 'Lógica',
  'Logica': 'Lógica',
  'ETICA': 'Ética',
  'Etica': 'Ética',
  'PRACTICA': 'Práctica',
  'Practica': 'Práctica',
};

/// Transforma nombres crudos de Moodle (ej. "Curso202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2")
/// en títulos limpios y legibles para estudiantes (ej. "Taller de Construcción de Software Móvil").
String formatCourseTitle(String raw) {
  if (raw.trim().isEmpty) return raw;
  String name = raw.trim();

  // 1. Eliminar prefijos con dos puntos ("Curso202W0907-2023-1: GESTION...")
  if (name.contains(':')) {
    final parts = name.split(':');
    if (parts.length > 1 && parts[1].trim().isNotEmpty) {
      name = parts.sublist(1).join(':').trim();
    }
  }

  // 2. Eliminar prefijo 'Curso' con su código (ej. 'Curso202W0907-', 'Curso-202W0907_')
  // IMPORTANTE: [A-Za-z0-9] no debe incluir guiones ni guiones bajos para no consumir el nombre del curso.
  name = name.replaceFirst(RegExp(r'^Curso[-_]?[A-Za-z0-9]+[-_:]\s*', caseSensitive: false), '');

  // 3. Eliminar códigos automáticos al inicio sin 'Curso' (ej. '202W0907-', '202W1001_', 'CUR-01-')
  name = name.replaceFirst(RegExp(r'^(?:[A-Za-z0-9]{2,10}[-_])?\d+[A-Za-z0-9]*[-_:]\s*'), '');
  name = name.replaceFirst(RegExp(r'^(?:CUR|MAT|INF|SIS|FIS|BIO|QUI|CS)[-_]\d+[-_:]\s*', caseSensitive: false), '');

  // 4. Eliminar sufijos de ciclo o periodo (-2018-1_26.2, -2023-1, _26.2)
  name = name.replaceFirst(RegExp(r'[-_]\d{4}[-_]\d.*$'), '');
  name = name.replaceFirst(RegExp(r'[-_]\d+(\.\d+)?$'), '');

  // 5. Reemplazar guiones bajos por espacios y normalizar espacios múltiples
  name = name.replaceAll('_', ' ');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

  // 6. Convertir MAYÚSCULAS sostenidas a Title Case humano con acentuación correcta
  if (name.length > 2 && name == name.toUpperCase()) {
    final words = name.split(' ');
    final titledWords = words.map((w) {
      if (w.isEmpty) return '';
      final lower = w.toLowerCase();
      final upper = w.toUpperCase();
      if (['de', 'del', 'la', 'las', 'el', 'los', 'en', 'y', 'para', 'con', 'a', 'o', 'por'].contains(lower)) {
        return lower;
      }
      if (_knownCourseAccents.containsKey(upper)) {
        return _knownCourseAccents[upper]!;
      }
      if (RegExp(r'^[A-Z]\d+$').hasMatch(w)) {
        return w; // ej: G1, G2 (secciones o grupos)
      }
      if (w == '-') return '-';
      return '${w[0].toUpperCase()}${lower.substring(1)}';
    }).toList();

    if (titledWords.isNotEmpty && titledWords.first.isNotEmpty) {
      titledWords[0] = '${titledWords[0][0].toUpperCase()}${titledWords[0].substring(1)}';
    }
    name = titledWords.join(' ');
  } else {
    // Si ya tiene minúsculas, restaurar tildes de palabras conocidas si faltan
    final words = name.split(' ');
    final restored = words.map((w) {
      return _knownCourseAccents[w] ?? w;
    }).toList();
    name = restored.join(' ');
  }

  return name.isNotEmpty ? name : raw;
}
