import 'package:flutter/foundation.dart';

import '../data/models/course_model.dart';
import '../data/services/api_service.dart';

enum CoursesStatus { loading, loaded, empty, error }

/// Estado de la pantalla "Mis cursos" (MVVM).
class CoursesViewModel extends ChangeNotifier {
  final ApiService apiService;

  CoursesViewModel({required this.apiService});

  List<CourseRiskSummary> _courses = [];
  RiskDistributionSummary _summary = const RiskDistributionSummary();
  String _studentName = 'Estudiante';
  String _studentId = 'EST-0001';
  CoursesStatus _status = CoursesStatus.loading;
  String? _error;
  bool _sortByPriority = true;
  DateTime? _lastSync;

  String get studentName => _studentName;
  String get studentId => _studentId;
  RiskDistributionSummary get summary => _summary;
  CoursesStatus get status => _status;
  String? get error => _error;
  bool get sortByPriority => _sortByPriority;
  bool get isLoading => _status == CoursesStatus.loading;

  String get iniciales {
    final partes = _studentName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
  }

  String get primerNombre {
    final partes = _studentName.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? _studentName : partes.first;
  }

  /// Cursos ordenados según el criterio activo.
  List<CourseRiskSummary> get courses {
    final list = [..._courses];
    if (_sortByPriority) {
      list.sort((a, b) {
        if (a.esSinEstimacion != b.esSinEstimacion) {
          return a.esSinEstimacion ? 1 : -1;
        }
        return b.porcentajeRiesgo.compareTo(a.porcentajeRiesgo);
      });
    } else {
      list.sort(
        (a, b) => a.cleanNombreCurso.toLowerCase().compareTo(b.cleanNombreCurso.toLowerCase()),
      );
    }
    return list;
  }

  String get lastSyncFormatted {
    final sync = _lastSync;
    if (sync == null) return 'Sin sincronizar';
    final hh = sync.hour.toString().padLeft(2, '0');
    final mm = sync.minute.toString().padLeft(2, '0');
    return 'Actualizado hoy, $hh:$mm';
  }

  void clear() {
    _studentId = '';
    _studentName = '';
    _courses = [];
    _summary = const RiskDistributionSummary();
    _status = CoursesStatus.loading;
    _error = null;
    _lastSync = null;
    notifyListeners();
  }

  Future<void> loadCourses({String? studentId, bool refresh = false}) async {
    final targetId = studentId ?? _studentId;
    if (_studentId.isNotEmpty && targetId.isNotEmpty && _studentId != targetId) {
      _courses = [];
      _summary = const RiskDistributionSummary();
    }
    _status = CoursesStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.getStudentCourses(
        targetId,
        refresh: refresh,
      );
      _studentId = response.idEstudiante.isNotEmpty
          ? response.idEstudiante
          : targetId;
      _studentName = response.nombreEstudiante;
      _summary = response.resumenRiesgo;
      _courses = response.cursos;
      _lastSync = DateTime.now();
      _status = _courses.isEmpty ? CoursesStatus.empty : CoursesStatus.loaded;
    } catch (e) {
      _error = 'No pudimos cargar tus cursos';
      _status = CoursesStatus.error;
    }
    notifyListeners();
  }

  void toggleSort() {
    _sortByPriority = !_sortByPriority;
    notifyListeners();
  }

  /// Permite a las pruebas y a la UI forzar estados de error/vacío.
  void simulateState(String state) {
    switch (state) {
      case 'empty':
        _courses = [];
        _status = CoursesStatus.empty;
        break;
      case 'error':
        _status = CoursesStatus.error;
        _error = 'No pudimos cargar tus cursos';
        break;
      default:
        _status = CoursesStatus.loaded;
    }
    notifyListeners();
  }
}
