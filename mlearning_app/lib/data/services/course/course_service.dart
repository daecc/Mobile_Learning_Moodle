import 'package:mlearning_early_warning/data/models/course/course_model.dart';

/// Interfaz abstracta para servicio de cursos/matrículas.
abstract class CourseService {
  /// Obtiene los cursos matriculados del estudiante actual.
  /// Retorna lista de [CourseEnrollment] con info de progreso, estado, etc.
  Future<List<CourseEnrollment>> getMyCourses(String studentId);

  /// Obtiene detalle completo de un curso específico.
  Future<Course> getCourseDetail(String courseId);

  /// Busca cursos por término (para búsqueda).
  Future<List<Course>> searchCourses(String query);
}

/// Implementación Mock con datos realistas basados en el dataset de riesgo.
/// Simula cursos de Ingeniería de Sistemas (ciclos 6-8).
class CourseServiceMock implements CourseService {
  static const Duration _networkDelay = Duration(milliseconds: 800);

  // Catálogo base de cursos (simula catálogo Moodle)
  static final List<Course> _catalogo = [
    Course(
      id: 'CUR-001',
      codigo: 'SI-301',
      nombre: 'Patrones de Diseño de Software',
      descripcion: 'Patrones creacionales, estructurales y de comportamiento. Aplicación en Java/Python.',
      creditos: 4,
      docente: 'Dr. Carlos Ramírez',
      docenteEmail: 'c.ramirez@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#1976D2', // Blue
      iconCodePoint: 0xE3AF, // code
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=301',
    ),
    Course(
      id: 'CUR-002',
      codigo: 'SI-302',
      nombre: 'Arquitectura de Software',
      descripcion: 'Estilos arquitectónicos, microservicios, patrones de integración, calidad de atributos.',
      creditos: 4,
      docente: 'Mg. Patricia Vargas',
      docenteEmail: 'p.vargas@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#7B1FA2', // Purple
      iconCodePoint: 0xE072, // account_tree
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=302',
    ),
    Course(
      id: 'CUR-003',
      codigo: 'SI-303',
      nombre: 'Base de Datos Avanzadas',
      descripcion: 'Optimización, particionamiento, NoSQL, Data Warehousing, Big Data.',
      creditos: 4,
      docente: 'Dr. Roberto Chen',
      docenteEmail: 'r.chen@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#388E3C', // Green
      iconCodePoint: 0xE2C4, // storage
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=303',
    ),
    Course(
      id: 'CUR-004',
      codigo: 'SI-304',
      nombre: 'Ingeniería de Requerimientos',
      descripcion: 'Elicitación, análisis, especificación y validación de requerimientos. Casos de uso.',
      creditos: 3,
      docente: 'Mg. Ana Torres',
      docenteEmail: 'a.torres@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#F57C00', // Orange
      iconCodePoint: 0xE8B0, // assignment
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=304',
    ),
    Course(
      id: 'CUR-005',
      codigo: 'SI-305',
      nombre: 'Pruebas y Calidad de Software',
      descripcion: 'Testing unitario, integración, automatización, TDD, métricas de calidad.',
      creditos: 3,
      docente: 'Dr. Luis Herrera',
      docenteEmail: 'l.herrera@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#C62828', // Red
      iconCodePoint: 0xE873, // bug_report
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=305',
    ),
    Course(
      id: 'CUR-006',
      codigo: 'SI-306',
      nombre: 'Desarrollo Móvil Avanzado',
      descripcion: 'Flutter/React Native, arquitectura limpia, CI/CD, publicación en stores.',
      creditos: 4,
      docente: 'Mg. Sandra Morales',
      docenteEmail: 's.morales@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#0097A7', // Cyan
      iconCodePoint: 0xE32B, // phone_android
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=306',
    ),
    Course(
      id: 'CUR-007',
      codigo: 'SI-307',
      nombre: 'Inteligencia Artificial Aplicada',
      descripcion: 'ML supervisado/no supervisado, despliegue de modelos, ética en IA.',
      creditos: 4,
      docente: 'Dr. Fernando Soto',
      docenteEmail: 'f.soto@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#6A1B9A', // Deep Purple
      iconCodePoint: 0xE3AE, // psychology
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=307',
    ),
    Course(
      id: 'CUR-008',
      codigo: 'SI-308',
      nombre: 'Gestión de Proyectos Ágiles',
      descripcion: 'Scrum, Kanban, escalamiento, métricas ágiles, herramientas Jira/GitLab.',
      creditos: 3,
      docente: 'Mg. Gabriela Ruiz',
      docenteEmail: 'g.ruiz@universidad.edu.pe',
      semestre: '2026-1',
      facultad: 'Facultad de Ingeniería',
      colorHex: '#2E7D32', // Green Dark
      iconCodePoint: 0xE8D2, // dashboard
      activo: true,
      fechaInicio: DateTime(2026, 3, 16),
      fechaFin: DateTime(2026, 7, 15),
      moodleUrl: 'https://moodle.universidad.edu.pe/course/view.php?id=308',
    ),
  ];

  // Matrículas por estudiante (simula tabla de matrícula en BD)
  static final Map<String, List<String>> _matriculas = {
    'EST-0001': ['CUR-001', 'CUR-002', 'CUR-003', 'CUR-007', 'CUR-008'], // 5 cursos
    'EST-0002': ['CUR-001', 'CUR-002', 'CUR-006', 'CUR-007'], // 4 cursos
    'EST-0003': ['CUR-001', 'CUR-002', 'CUR-003', 'CUR-006', 'CUR-007'], // 5 cursos
    'EST-0004': ['CUR-002', 'CUR-004', 'CUR-005', 'CUR-006'], // 4 cursos
  };

  // Progreso simulado por estudiante-curso (0-100)
  static final Map<String, Map<String, double>> _progreso = {
    'EST-0001': {'CUR-001': 65, 'CUR-002': 72, 'CUR-003': 45, 'CUR-007': 38, 'CUR-008': 55},
    'EST-0002': {'CUR-001': 88, 'CUR-002': 91, 'CUR-006': 79, 'CUR-007': 82},
    'EST-0003': {'CUR-001': 95, 'CUR-002': 93, 'CUR-003': 89, 'CUR-006': 92, 'CUR-007': 87},
    'EST-0004': {'CUR-002': 60, 'CUR-004': 70, 'CUR-005': 50, 'CUR-006': 65},
  };

  // Tareas pendientes simuladas
  static final Map<String, Map<String, int>> _tareasPendientes = {
    'EST-0001': {'CUR-001': 2, 'CUR-002': 1, 'CUR-003': 3, 'CUR-007': 4, 'CUR-008': 2},
    'EST-0002': {'CUR-001': 0, 'CUR-002': 1, 'CUR-006': 2, 'CUR-007': 1},
    'EST-0003': {'CUR-001': 0, 'CUR-002': 0, 'CUR-003': 1, 'CUR-006': 0, 'CUR-007': 1},
    'EST-0004': {'CUR-002': 2, 'CUR-004': 3, 'CUR-005': 4, 'CUR-006': 1},
  };

  // Última actividad simulada
  static final Map<String, Map<String, DateTime>> _ultimaActividad = {
    'EST-0001': {
      'CUR-001': DateTime(2026, 6, 5),
      'CUR-002': DateTime(2026, 6, 7),
      'CUR-003': DateTime(2026, 6, 3),
      'CUR-007': DateTime(2026, 6, 8),
      'CUR-008': DateTime(2026, 6, 6),
    },
    'EST-0002': {
      'CUR-001': DateTime(2026, 6, 8),
      'CUR-002': DateTime(2026, 6, 8),
      'CUR-006': DateTime(2026, 6, 7),
      'CUR-007': DateTime(2026, 6, 8),
    },
    'EST-0003': {
      'CUR-001': DateTime(2026, 6, 8),
      'CUR-002': DateTime(2026, 6, 8),
      'CUR-003': DateTime(2026, 6, 8),
      'CUR-006': DateTime(2026, 6, 8),
      'CUR-007': DateTime(2026, 6, 8),
    },
    'EST-0004': {
      'CUR-002': DateTime(2026, 6, 6),
      'CUR-004': DateTime(2026, 6, 5),
      'CUR-005': DateTime(2026, 6, 4),
      'CUR-006': DateTime(2026, 6, 7),
    },
  };

  @override
  Future<List<CourseEnrollment>> getMyCourses(String studentId) async {
    await Future.delayed(_networkDelay);

    final courseIds = _matriculas[studentId] ?? [];

    return courseIds.map((courseId) {
      final course = _catalogo.firstWhere((c) => c.id == courseId);
      final progreso = _progreso[studentId]?[courseId] ?? 0.0;
      final tareas = _tareasPendientes[studentId]?[courseId] ?? 0;
      final ultimaAct = _ultimaActividad[studentId]?[courseId];

      // Determinar estado basado en progreso y fechas
      String estado;
      final now = DateTime.now();
      if (course.fechaFin != null && now.isAfter(course.fechaFin!)) {
        estado = 'finalizado';
      } else if (progreso >= 100) {
        estado = 'finalizado';
      } else if (course.activo) {
        estado = 'activo';
      } else {
        estado = 'inactivo';
      }

      return CourseEnrollment(
        course: course,
        estado: estado,
        progresoPorcentaje: progreso,
        tareasPendientes: tareas,
        ultimaActividad: ultimaAct,
      );
    }).toList();
  }

  @override
  Future<Course> getCourseDetail(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final course = _catalogo.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw Exception('Curso no encontrado: $courseId'),
    );

    return course;
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    return _catalogo.where((c) {
      return c.nombre.toLowerCase().contains(lowerQuery) ||
          c.codigo.toLowerCase().contains(lowerQuery) ||
          c.docente.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}