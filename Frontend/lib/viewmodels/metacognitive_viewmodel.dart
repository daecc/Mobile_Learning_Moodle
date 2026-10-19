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
  List<CourseMetacognitive> _cursos = [];
  List<String> _reflexionOpciones = [];

  MetacognitiveStatus get status => _status;
  bool get isLoading => _status == MetacognitiveStatus.loading;
  List<CourseMetacognitive> get cursos => _cursos;
  List<String> get reflexionOpciones => _reflexionOpciones;

  int get tareasTotales => _cursos.fold(0, (s, c) => s + c.tareasTotales);
  int get tareasEntregadas => _cursos.fold(0, (s, c) => s + c.tareasEntregadas);

  /// Accesos semanales sumados de todos los cursos (índice a índice).
  /// Si los cursos reportan distinta cantidad de semanas, se alinean por el final.
  List<num> get accesosSemanales {
    final series =
        _cursos.map((c) => c.accesosSemanales).where((s) => s.isNotEmpty);
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

  Future<void> load(List<CourseRiskSummary> cursos, String studentId) async {
    if (cursos.isEmpty) {
      _status = MetacognitiveStatus.idle;
      _cursos = [];
      notifyListeners();
      return;
    }

    _status = MetacognitiveStatus.loading;
    notifyListeners();

    try {
      final detalles = await Future.wait(
        cursos.map((c) => apiService.getCourseRiskDetail(studentId, c.idCurso)),
      );

      final resultado = <CourseMetacognitive>[];
      final opciones = <String>[];

      for (var i = 0; i < cursos.length; i++) {
        final detalle = detalles[i];
        var pendientes = 0;
        var totales = 0;
        for (final m in detalle.metricas) {
          if (m.clave == 'entregas') {
            // El backend envía "pendientes de totales", p. ej. "1 de 3".
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
