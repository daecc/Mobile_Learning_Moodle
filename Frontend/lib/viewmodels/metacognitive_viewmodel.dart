import 'package:flutter/foundation.dart';

import '../data/models/course_model.dart';
import '../data/models/risk_detail_model.dart';
import '../data/services/api_service.dart';

enum MetacognitiveStatus { idle, loading, loaded, error }

/// Métricas de autorregulación de un curso, tomadas del detalle de riesgo.
class CourseMetacognitive {
  final CourseRiskSummary curso;
  final List<MetacognitiveStat> metricas;
  final List<num> accesosSemanales;
  final int tareasPendientes;
  final int tareasTotales;

  const CourseMetacognitive({
    required this.curso,
    this.metricas = const [],
    this.accesosSemanales = const [],
    this.tareasPendientes = 0,
    this.tareasTotales = 0,
  });

  int get tareasEntregadas =>
      (tareasTotales - tareasPendientes).clamp(0, tareasTotales);
}

/// Estado del panel de Control Metacognitivo (MVVM).
///
/// Reúne, para todos los cursos del estudiante, las métricas que el backend
/// ya expone en `/riesgo`: inactividad, promedio, tareas y accesos semanales.
class MetacognitiveViewModel extends ChangeNotifier {
  final ApiService apiService;

  MetacognitiveViewModel({required this.apiService});

  MetacognitiveStatus _status = MetacognitiveStatus.idle;
  String? _currentStudentId;
  List<CourseMetacognitive> _cursos = [];
  List<String> _reflexionOpciones = [];

  MetacognitiveStatus get status => _status;
  bool get isLoading => _status == MetacognitiveStatus.loading;
  String? get currentStudentId => _currentStudentId;
  List<CourseMetacognitive> get cursos => _cursos;
  List<String> get reflexionOpciones => _reflexionOpciones;

  void clear() {
    _status = MetacognitiveStatus.idle;
    _currentStudentId = null;
    _cursos = [];
    _reflexionOpciones = [];
    _cursosRevisadosEstaSemana.clear();
    notifyListeners();
  }

  int get tareasTotales => cursos.fold(0, (s, c) => s + c.tareasTotales);
  int get tareasEntregadas => cursos.fold(0, (s, c) => s + c.tareasEntregadas);
  int get tareasPendientes => cursos.fold(0, (s, c) => s + c.tareasPendientes);

  /// Accesos semanales sumados de todos los cursos (índice a índice).
  /// Si los cursos reportan distinta cantidad de semanas, se alinean por el final.
  List<num> get accesosSemanales {
    final series =
        cursos.map((c) => c.accesosSemanales).where((s) => s.isNotEmpty);
    if (series.isEmpty) return const [];
    final largo = series.map((s) => s.length).reduce((a, b) => a > b ? a : b);
    final total = List<num>.filled(largo, 0);
    for (final s in series) {
      final offset = largo - s.length;
      for (var i = 0; i < s.length; i++) {
        total[offset + i] += s[i];
      }
    }
    return total;
  }

  /// Días con actividad de estudio durante los últimos 7 días.
  /// Si el factor contiene la comparación [dias_activos, meta_recomendada (4.0)],
  /// toma el primer elemento correspondiente a los días reales del estudiante.
  int get diasActivosSemanales {
    if (cursos.isEmpty) return 0;
    var maxDias = 0;
    for (final c in cursos) {
      if (c.accesosSemanales.isEmpty) continue;
      final dias = c.accesosSemanales.length == 2
          ? c.accesosSemanales[0].toInt()
          : c.accesosSemanales.last.toInt();
      if (dias > maxDias) {
        maxDias = dias;
      }
    }
    if (maxDias == 0) {
      final entroHoy = cursos.any((c) {
        final inact =
            c.metricas.where((m) => m.clave == 'inactividad').firstOrNull;
        return inact != null && inact.valor == '0';
      });
      if (entroHoy) maxDias = 1;
    }
    return maxDias.clamp(0, 7);
  }

  /// Semanas anteriores donde el estudiante cumplió la meta de 4 días de conexión
  int get semanasPreviasConstancia {
    if (cursos.isEmpty) return 0;
    final series = accesosSemanales;
    if (series.length <= 1) return 0;
    var completadas = 0;
    for (var i = 0; i < series.length - 1; i++) {
      if (series[i] >= 4) {
        completadas++;
      }
    }
    return completadas;
  }

  /// Clave de la semana actual (usando el lunes como inicio de semana: YYYY_MM_DD)
  String get _semanaActualKey {
    final now = DateTime.now();
    final lunes = now.subtract(Duration(days: now.weekday - 1));
    return '${lunes.year}_${lunes.month}_${lunes.day}';
  }

  String _semanaRegistrada = '';
  final Set<String> _cursosRevisadosEstaSemana = {};
  int _semanasPreviasCompletadas = 0;

  /// Cursos cuyo diagnóstico explicativo («¿Por qué este resultado?») ha sido revisado esta semana
  Set<String> get cursosRevisadosEstaSemana {
    _verificarSemana();
    return Set.unmodifiable(_cursosRevisadosEstaSemana);
  }

  /// Semanas pasadas donde el estudiante revisó todos sus cursos matriculados
  int get semanasPreviasEstratega => _semanasPreviasCompletadas;

  void _verificarSemana() {
    final key = _semanaActualKey;
    if (_semanaRegistrada != key) {
      _semanaRegistrada = key;
      _cursosRevisadosEstaSemana.clear();
    }
  }

  /// Registra la consulta del diagnóstico detallado de un curso por parte del estudiante
  void registrarRevisionDiagnostico(String courseId, {String? studentId}) {
    if (courseId.isEmpty) return;
    _verificarSemana();
    if (_cursosRevisadosEstaSemana.add(courseId)) {
      notifyListeners();
    }
    final sId = studentId ?? _currentStudentId;
    if (sId != null && sId.isNotEmpty) {
      apiService.recordDiagnosticReview(sId, courseId).then((res) {
        _semanasPreviasCompletadas = res.semanasPreviasCompletadas;
        notifyListeners();
      }).catchError((_) {});
    }
  }

  Future<void> load(
    List<CourseRiskSummary> cursos,
    String studentId, {
    bool refresh = false,
  }) async {
    // Si cambió el estudiante o se solicita recarga, resetear de inmediato los datos previos
    if (_currentStudentId != studentId || refresh) {
      _cursos = [];
      _reflexionOpciones = [];
      _cursosRevisadosEstaSemana.clear();
      _semanasPreviasCompletadas = 0;
      _currentStudentId = studentId;
    }

    // Cargar revisiones de diagnóstico persistidas de esta semana desde el backend
    try {
      final revs = await apiService.getDiagnosticReviews(studentId);
      _verificarSemana();
      _cursosRevisadosEstaSemana.addAll(revs.cursosRevisados);
      _semanasPreviasCompletadas = revs.semanasPreviasCompletadas;
    } catch (_) {}

    if (cursos.isEmpty || studentId.isEmpty) {
      _status = MetacognitiveStatus.idle;
      _cursos = [];
      notifyListeners();
      return;
    }

    _status = MetacognitiveStatus.loading;
    notifyListeners();

    try {
      final detalles = await Future.wait(
        cursos.map((c) => apiService.getCourseRiskDetail(
              studentId,
              c.idCurso,
              refresh: refresh,
            )),
      );

      final resultado = <CourseMetacognitive>[];
      final opciones = <String>[];

      for (var i = 0; i < cursos.length; i++) {
        final detalle = detalles[i];
        var pendientes = 0;
        var totales = 0;
        for (final m in detalle.metricas) {
          if (m.clave == 'entregas' || m.clave == 'procrastinacion') {
            // El backend envía "pendientes de totales", p. ej. "1 de 3" o "3 de 3 (...)".
            final partes = RegExp(r'(\d+)\s*de\s*(\d+)').firstMatch(m.valor);
            if (partes != null) {
              pendientes = int.parse(partes.group(1)!);
              totales = int.parse(partes.group(2)!);
            }
          }
        }

        final factores = [
          ...?detalle.factores?.riesgos,
          ...?detalle.factores?.favorables,
        ];
        final accesos = factores
            .where((f) => f.chartType == 'weekly_logins')
            .map((f) => f.chartValues)
            .firstOrNull;

        if (opciones.isEmpty && detalle.factores != null) {
          opciones.addAll(detalle.factores!.reflexionOpciones);
        }

        resultado.add(CourseMetacognitive(
          curso: cursos[i],
          metricas: detalle.metricas,
          accesosSemanales: accesos ?? const [],
          tareasPendientes: pendientes,
          tareasTotales: totales,
        ));
      }

      _cursos = resultado;
      _reflexionOpciones = opciones;
      _status = MetacognitiveStatus.loaded;
    } catch (_) {
      _status = MetacognitiveStatus.error;
    }
    notifyListeners();
  }
}
