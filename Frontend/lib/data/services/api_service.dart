import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/course_model.dart';
import '../models/risk_detail_model.dart';
import '../models/student_model.dart';
import '../models/chat_message_model.dart';

/// Cliente HTTP hacia la Rumbo API con respaldo offline (dataset de demostración).
///
/// Los métodos [getDemoCourses] y [getDemoRiskDetail] exponen la data local que
/// permite operar la aplicación sin backend. Cualquier fallo de red cae a esta
/// información para mantener la experiencia de usuario.
class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  // ---------------------------------------------------------------------------
  // Autenticación
  // ---------------------------------------------------------------------------

  Future<Student> login(String codigo, String password) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl${ApiConstants.loginEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'codigo': codigo, 'password': password}),
          )
          .timeout(ApiConstants.timeout);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        return Student.fromJson(body['estudiante'] as Map<String, dynamic>);
      }

      // Manejo explícito de errores devueltos por el backend
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('detail')) {
          throw Exception(body['detail']);
        }
      } catch (e) {
        if (e.toString().contains('Exception: ')) rethrow;
      }

      throw Exception('Error al autenticar (${resp.statusCode}).');
    } catch (e) {
      // Si el código es explícitamente DEMO o no hay red y se requiere modo demo
      if (codigo.trim().toUpperCase() == 'DEMO') {
        return demoStudent;
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Cursos
  // ---------------------------------------------------------------------------

  /// Obtiene los cursos del estudiante. Si la API no responde, usa la copia local.
  Future<StudentCoursesResponse> getStudentCourses(String studentId) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl${ApiConstants.coursesEndpoint}/$studentId/cursos'))
          .timeout(ApiConstants.timeout);
      if (resp.statusCode == 200) {
        return StudentCoursesResponse.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Respuesta ${resp.statusCode}');
    } catch (_) {
      return getDemoCourses(studentId);
    }
  }

  /// Detalle de riesgo de un curso. Si la API no responde, usa la copia local.
  Future<RiskDetailResponse> getCourseRiskDetail(
    String studentId,
    String courseId,
  ) async {
    try {
      final resp = await _client
          .get(
            Uri.parse(
              '$baseUrl${ApiConstants.coursesEndpoint}/$studentId/cursos/$courseId/riesgo',
            ),
          )
          .timeout(ApiConstants.timeout);
      if (resp.statusCode == 200) {
        return RiskDetailResponse.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Respuesta ${resp.statusCode}');
    } catch (_) {
      return getDemoRiskDetail(studentId, courseId);
    }
  }

  // ---------------------------------------------------------------------------
  // Tutor Inteligente IA
  // ---------------------------------------------------------------------------

  Future<TutorChatResponseModel> sendMessageToTutor({
    required String studentId,
    String? courseId,
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl${ApiConstants.tutorEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id_estudiante': studentId,
              'id_curso': courseId,
              'mensaje': message,
              'historial': history,
            }),
          )
          .timeout(ApiConstants.timeout);

      if (resp.statusCode == 200) {
        return TutorChatResponseModel.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Error del tutor (${resp.statusCode})');
    } catch (e) {
      // Fallback local en caso de desconexión
      return TutorChatResponseModel(
        respuesta:
            'Hola, estoy operando en modo local asistido. Para mejorar tu desempeño, te recomiendo ingresar con frecuencia a Moodle y priorizar las tareas pendientes para mantener tu riesgo en zona segura.',
        sugerencias: [
          '¿Cómo organizo mis horarios?',
          'Tips para estudiar mejor',
          'Revisar mis tareas',
        ],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Data de demostración (offline)
  // ---------------------------------------------------------------------------

  static const Student demoStudent = Student(
    idEstudiante: 'EST-0001',
    nombre: 'Valeria Quispe',
    carrera: 'Ingeniería de Software',
    ciclo: 'Pregrado',
    email: 'valeria.quispe@universidad.edu.pe',
  );

  StudentCoursesResponse getDemoCourses(String studentId) {
    return StudentCoursesResponse(
      idEstudiante: demoStudent.idEstudiante,
      nombreEstudiante: demoStudent.nombre,
      totalCursos: _demoCourses.length,
      resumenRiesgo: const RiskDistributionSummary(
        bajo: 1,
        moderado: 2,
        critico: 1,
        sinEstimacion: 1,
      ),
      cursos: _demoCourses,
    );
  }

  static const List<CourseRiskSummary> _demoCourses = [
    CourseRiskSummary(
      idCurso: 'CUR-001',
      nombreCurso: 'Patrones de Diseño de Software',
      codigoCurso: 'IS-401',
      creditos: 4,
      docente: 'Mg. Carlos Mendoza',
      probabilidadRiesgo: 0.85,
      porcentajeRiesgo: 85,
      nivelRiesgo: 'CRITICO',
    ),
    CourseRiskSummary(
      idCurso: 'CUR-002',
      nombreCurso: 'Ingeniería de Requisitos',
      codigoCurso: 'IS-402',
      creditos: 4,
      docente: 'Ing. Renzo Huamán',
      probabilidadRiesgo: 0.52,
      porcentajeRiesgo: 52,
      nivelRiesgo: 'MODERADO',
    ),
    CourseRiskSummary(
      idCurso: 'CUR-003',
      nombreCurso: 'Arquitectura de Software',
      codigoCurso: 'IS-403',
      creditos: 3,
      docente: 'Dr. Fernando Quispe',
      probabilidadRiesgo: 0.41,
      porcentajeRiesgo: 41,
      nivelRiesgo: 'MODERADO',
    ),
    CourseRiskSummary(
      idCurso: 'CUR-004',
      nombreCurso: 'Base de Datos II',
      codigoCurso: 'IS-404',
      creditos: 4,
      docente: 'Mg. Patricia Morales',
      probabilidadRiesgo: 0.18,
      porcentajeRiesgo: 18,
      nivelRiesgo: 'BAJO',
    ),
    CourseRiskSummary(
      idCurso: 'CUR-005',
      nombreCurso: 'Gestión de Proyectos de Software',
      codigoCurso: 'IS-405',
      creditos: 3,
      docente: 'Ing. Jorge Alarcón',
      probabilidadRiesgo: -1.0,
      porcentajeRiesgo: -1,
      nivelRiesgo: 'SIN_ESTIMACION',
      fechaEstimacion: 'Desde el 19 de oct.',
    ),
  ];

  RiskDetailResponse getDemoRiskDetail(String studentId, String courseId) {
    switch (courseId) {
      case 'CUR-001':
        return _criticoPatrones;
      case 'CUR-002':
        return _moderadoRequisitos;
      case 'CUR-003':
        return _moderadoArquitectura;
      case 'CUR-005':
        return _sinEstimacionGestion;
      case 'CUR-004':
      default:
        return _seguroBaseDatos;
    }
  }

  static const RiskDetailResponse _criticoPatrones = RiskDetailResponse(
    idEstudiante: 'EST-0001',
    idCurso: 'CUR-001',
    nombreCurso: 'Patrones de Diseño de Software',
    codigoCurso: 'IS-401',
    fechaCorte: '2026-10-14',
    probabilidadRiesgo: 0.85,
    porcentajeRiesgo: 85,
    nivelRiesgo: 'CRITICO',
    alertaTitulo: 'ALERTA TEMPRANA',
    alertaMensaje: 'Detectamos señales de riesgo. Aún estás a tiempo de mejorar.',
    accionRecomendada:
        'Conéctate hoy a Moodle, revisa las tareas vencidas y solicita una tutoría.',
    rangoMin: 78,
    rangoMax: 91,
    pasoTitulo: 'Prioridad inmediata',
    pasoSubtitulo: 'Entrega la Tarea 4: Patrón Observer',
    pasoTipo: 'task',
    actualizadoLabel: 'Actualizado hoy, 07:30 · se recalcula a diario',
    siguientePasoDetalle: 'Vence el viernes 16 de octubre',
    factores: FactoresBundle(
      periodo: 'últimas 4 semanas',
      sumanRiesgo: 4,
      jueganFavor: 2,
      reflexionOpciones: [
        'Organizar mi tiempo',
        'Entender los temas',
        'Participar más en clase',
        'No estoy seguro',
      ],
      riesgos: [
        RiskFactor(
          clave: 'inactividad',
          titulo: 'Llevas 5 días sin entrar al curso',
          subtitulo: 'Antes entrabas cada 2 días, en promedio.',
          impacto: 'aumenta',
          influencia: 3,
          chartType: 'day_circles',
          chartValues: [1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
        ),
        RiskFactor(
          clave: 'cuestionarios',
          titulo: 'Tu promedio en los últimos 3 cuestionarios es 11/20',
          subtitulo: 'Empezaste con 14 y ha ido bajando de a poco.',
          impacto: 'aumenta',
          influencia: 3,
          chartType: 'quiz_trend',
          chartValues: [14, 12, 11],
        ),
        RiskFactor(
          clave: 'tareas',
          titulo: 'Tienes 2 tareas pendientes',
          subtitulo: 'Entregaste 3 de 5. La Tarea 4 vence el viernes 16.',
          impacto: 'aumenta',
          influencia: 2,
          chartType: 'tasks_timeline',
          chartValues: [1, 1, 1, 0, 0],
        ),
        RiskFactor(
          clave: 'accesos',
          titulo: 'Esta semana entraste 1 vez',
          subtitulo: 'La mayoría de tu sección entra unas 4 veces por semana.',
          impacto: 'aumenta',
          influencia: 2,
          chartType: 'weekly_logins',
          chartValues: [1, 2, 0, 1, 4],
        ),
      ],
      favorables: [
        RiskFactor(
          clave: 'parcial',
          titulo: 'Sacaste 14/20 en el examen parcial',
          subtitulo: 'Demuestra que entiendes la base del curso.',
          impacto: 'reduce',
          influencia: 2,
        ),
        RiskFactor(
          clave: 'entregas',
          titulo: 'Entregaste a tiempo tus 3 primeras tareas',
          subtitulo: 'La constancia sostiene tu avance.',
          impacto: 'reduce',
          influencia: 2,
        ),
      ],
    ),
  );

  static const RiskDetailResponse _moderadoRequisitos = RiskDetailResponse(
    idEstudiante: 'EST-0001',
    idCurso: 'CUR-002',
    nombreCurso: 'Ingeniería de Requisitos',
    codigoCurso: 'IS-402',
    fechaCorte: '2026-10-14',
    probabilidadRiesgo: 0.52,
    porcentajeRiesgo: 52,
    nivelRiesgo: 'MODERADO',
    alertaTitulo: 'Atención requerida',
    alertaMensaje: 'Hay algunas señales que conviene atender.',
    accionRecomendada:
        'Planifica tus próximas 48 horas y entrega los ejercicios pendientes.',
    rangoMin: 44,
    rangoMax: 60,
    pasoTitulo: 'Qué puedes hacer ahora',
    pasoSubtitulo: 'Entrega la Tarea 2: Casos de uso',
    pasoTipo: 'task',
    actualizadoLabel: 'Actualizado hoy, 07:30 · se recalcula a diario',
    siguientePasoDetalle: 'Vence el martes 15 de octubre',
  );

  static const RiskDetailResponse _moderadoArquitectura = RiskDetailResponse(
    idEstudiante: 'EST-0001',
    idCurso: 'CUR-003',
    nombreCurso: 'Arquitectura de Software',
    codigoCurso: 'IS-403',
    fechaCorte: '2026-10-14',
    probabilidadRiesgo: 0.41,
    porcentajeRiesgo: 41,
    nivelRiesgo: 'MODERADO',
    alertaTitulo: 'Atención requerida',
    alertaMensaje: 'Hay algunas señales que conviene atender.',
    accionRecomendada:
        'Revisa el último módulo práctico y resuelve las dudas con el docente.',
    rangoMin: 33,
    rangoMax: 49,
    pasoTitulo: 'Qué puedes hacer ahora',
    pasoSubtitulo: 'Repasa el módulo de vistas arquitectónicas',
    pasoTipo: 'task',
    actualizadoLabel: 'Actualizado hoy, 07:30 · se recalcula a diario',
  );

  static const RiskDetailResponse _seguroBaseDatos = RiskDetailResponse(
    idEstudiante: 'EST-0001',
    idCurso: 'CUR-004',
    nombreCurso: 'Base de Datos II',
    codigoCurso: 'IS-404',
    fechaCorte: '2026-10-14',
    probabilidadRiesgo: 0.18,
    porcentajeRiesgo: 18,
    nivelRiesgo: 'BAJO',
    alertaTitulo: 'Vas por buen camino',
    alertaMensaje: 'Vas por buen camino en este curso.',
    accionRecomendada:
        'Mantén tu ritmo constante y participa en los foros del curso.',
    rangoMin: 11,
    rangoMax: 27,
    pasoTitulo: 'Para mantener el ritmo',
    pasoSubtitulo: 'Cuestionario 4: Normalización',
    pasoTipo: 'quiz',
    actualizadoLabel: 'Actualizado hoy, 07:30 · se recalcula a diario',
    siguientePasoDetalle: 'Se abre el miércoles 14 de octubre',
    factores: FactoresBundle(
      periodo: 'últimas 4 semanas',
      sumanRiesgo: 1,
      jueganFavor: 4,
      reflexionOpciones: [
        'Organizar mi tiempo',
        'Entender los temas',
        'Participar más en clase',
        'No estoy seguro',
      ],
      riesgos: [
        RiskFactor(
          clave: 'cuestionarios',
          titulo: 'Tu promedio en cuestionarios es 17/20',
          subtitulo: 'Vas bien, mantén el ritmo de repaso.',
          impacto: 'aumenta',
          influencia: 1,
          chartType: 'quiz_trend',
          chartValues: [16, 17, 17],
        ),
      ],
      favorables: [
        RiskFactor(
          clave: 'entregas',
          titulo: 'Has completado el 100% de entregas',
          subtitulo: 'Entregaste todas las tareas a tiempo.',
          impacto: 'reduce',
          influencia: 3,
        ),
        RiskFactor(
          clave: 'accesos',
          titulo: 'Entras al curso 5 veces por semana',
          subtitulo: 'Por encima del promedio de tu sección.',
          impacto: 'reduce',
          influencia: 2,
        ),
        RiskFactor(
          clave: 'materiales',
          titulo: 'Revisaste el 90% de los materiales',
          subtitulo: 'Consultas las lecturas y diapositivas.',
          impacto: 'reduce',
          influencia: 2,
        ),
        RiskFactor(
          clave: 'participacion',
          titulo: 'Participas activamente en los foros',
          subtitulo: 'Tus aportes ayudan a consolidar el tema.',
          impacto: 'reduce',
          influencia: 2,
        ),
      ],
    ),
  );

  static const RiskDetailResponse _sinEstimacionGestion = RiskDetailResponse(
    idEstudiante: 'EST-0001',
    idCurso: 'CUR-005',
    nombreCurso: 'Gestión de Proyectos de Software',
    codigoCurso: 'IS-405',
    fechaCorte: '2026-10-14',
    probabilidadRiesgo: -1.0,
    porcentajeRiesgo: -1,
    nivelRiesgo: 'SIN_ESTIMACION',
    alertaTitulo: 'Sin estimación todavía',
    alertaMensaje: 'Aún no hay suficiente actividad para estimar',
    accionRecomendada: 'Ingresa al curso para que podamos calcular tu riesgo.',
    rangoMin: 0,
    rangoMax: 0,
    actualizadoLabel: 'Revisado hoy, 07:30',
    mensajeSinEstimacion: 'Aún no hay suficiente actividad para estimar',
    progresoSemana: 'Semana 1 de 2',
    progresoActual: 1,
    progresoTotal: 2,
  );
}
