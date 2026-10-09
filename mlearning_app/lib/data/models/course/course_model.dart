import 'package:flutter/material.dart';

/// Modelo de curso/materia en el que el estudiante está matriculado.
/// Basado en la estructura de Moodle y el dataset de riesgo académico.
class Course {
  /// ID único del curso (ej. 'CUR-007')
  final String id;

  /// Código corto visible (ej. 'SI-301')
  final String codigo;

  /// Nombre completo del curso
  final String nombre;

  /// Descripción breve
  final String? descripcion;

  /// Créditos académicos
  final int creditos;

  /// Docente a cargo
  final String docente;

  /// Email del docente
  final String? docenteEmail;

  /// Semestre / Ciclo (ej. '2026-1')
  final String semestre;

  /// Facultad / Departamento
  final String facultad;

  /// Color temático para UI (hex)
  final String colorHex;

  /// Icono identificador (Material icon code point)
  final int iconCodePoint;

  /// Si el curso está activo en el semestre actual
  final bool activo;

  /// Fecha de inicio del curso
  final DateTime? fechaInicio;

  /// Fecha de fin del curso
  final DateTime? fechaFin;

  /// URL del curso en Moodle (para deep linking)
  final String? moodleUrl;

  Course({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.creditos,
    required this.docente,
    this.docenteEmail,
    required this.semestre,
    required this.facultad,
    required this.colorHex,
    required this.iconCodePoint,
    required this.activo,
    this.fechaInicio,
    this.fechaFin,
    this.moodleUrl,
  });

  /// Color parsed para UI
  Color get color => _parseColor(colorHex);

  /// IconData para UI
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Factory desde JSON (API Moodle / Backend)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id_curso'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      creditos: json['creditos'] as int,
      docente: json['docente'] as String,
      docenteEmail: json['docente_email'] as String?,
      semestre: json['semestre'] as String,
      facultad: json['facultad'] as String,
      colorHex: json['color_hex'] as String? ?? '#1976D2',
      iconCodePoint: json['icon_code'] as int? ?? 0xE80B, // school
      activo: json['activo'] as bool? ?? true,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      moodleUrl: json['moodle_url'] as String?,
    );
  }

  /// A JSON
  Map<String, dynamic> toJson() {
    return {
      'id_curso': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'creditos': creditos,
      'docente': docente,
      'docente_email': docenteEmail,
      'semestre': semestre,
      'facultad': facultad,
      'color_hex': colorHex,
      'icon_code': iconCodePoint,
      'activo': activo,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'moodle_url': moodleUrl,
    };
  }

  /// Copia con actualizaciones
  Course copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    int? creditos,
    String? docente,
    String? docenteEmail,
    String? semestre,
    String? facultad,
    String? colorHex,
    int? iconCodePoint,
    bool? activo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? moodleUrl,
  }) {
    return Course(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      creditos: creditos ?? this.creditos,
      docente: docente ?? this.docente,
      docenteEmail: docenteEmail ?? this.docenteEmail,
      semestre: semestre ?? this.semestre,
      facultad: facultad ?? this.facultad,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      activo: activo ?? this.activo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      moodleUrl: moodleUrl ?? this.moodleUrl,
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

  @override
  String toString() => 'Course(id: $id, codigo: $codigo, nombre: $nombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Resumen de matrícula del estudiante en un curso (para dashboard)
class CourseEnrollment {
  final Course course;
  final String estado; // 'activo', 'finalizado', 'retirado'
  final double? progresoPorcentaje; // 0-100
  final int? tareasPendientes;
  final DateTime? ultimaActividad;

  CourseEnrollment({
    required this.course,
    required this.estado,
    this.progresoPorcentaje,
    this.tareasPendientes,
    this.ultimaActividad,
  });

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      estado: json['estado'] as String,
      progresoPorcentaje: (json['progreso_porcentaje'] as num?)?.toDouble(),
      tareasPendientes: json['tareas_pendientes'] as int?,
      ultimaActividad: json['ultima_actividad'] != null
          ? DateTime.parse(json['ultima_actividad'] as String)
          : null,
    );
  }
}