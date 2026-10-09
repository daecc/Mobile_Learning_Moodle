import 'package:flutter/foundation.dart';
import 'package:mlearning_early_warning/data/models/course/course_model.dart';
import 'package:mlearning_early_warning/data/services/course/course_service.dart';

/// Estados de carga del dashboard de cursos.
enum CoursesViewState {
  initial,
  loading,
  success,
  error,
}

/// ViewModel para el Dashboard de Cursos (Mis Cursos).
///
/// Responsabilidades:
/// - Cargar matrículas del estudiante autenticado
/// - Exponer lista de CourseEnrollment lista para UI
/// - Manejar pull-to-refresh
/// - Filtrar/buscar cursos (futuro)
class CoursesViewModel extends ChangeNotifier {
  final CourseService _courseService;
  final String _studentId;

  CoursesViewState _state = CoursesViewState.initial;
  List<CourseEnrollment> _courses = [];
  String? _errorMessage;

  CoursesViewModel({
    required CourseService courseService,
    required String studentId,
  })  : _courseService = courseService,
        _studentId = studentId;

  /// Student ID para identificar al usuario (usado por ChangeNotifierProxyProvider)
  String get studentId => _studentId;

  // Getters
  CoursesViewState get state => _state;
  List<CourseEnrollment> get courses => _courses;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CoursesViewState.loading;
  bool get hasData => _state == CoursesViewState.success && _courses.isNotEmpty;
  bool get hasError => _state == CoursesViewState.error;
  bool get isEmpty => _state == CoursesViewState.success && _courses.isEmpty;

  /// Solo cursos activos
  List<CourseEnrollment> get activeCourses =>
      _courses.where((e) => e.estado == 'activo').toList();

  /// Solo cursos finalizados
  List<CourseEnrollment> get finishedCourses =>
      _courses.where((e) => e.estado == 'finalizado').toList();

  /// Total de créditos del semestre
  int get totalCreditos =>
      _courses.fold(0, (sum, e) => sum + e.course.creditos);

  /// Cursos con tareas pendientes
  List<CourseEnrollment> get coursesWithPendingTasks =>
      _courses.where((e) => (e.tareasPendientes ?? 0) > 0).toList();

  /// Carga inicial de cursos
  Future<void> loadCourses() async {
    if (_state == CoursesViewState.loading) return;

    _setState(CoursesViewState.loading);

    try {
      final courses = await _courseService.getMyCourses(_studentId);
      _courses = courses;
      _errorMessage = null;
      _setState(CoursesViewState.success);
    } catch (e) {
      _errorMessage = _mapError(e);
      _courses = [];
      _setState(CoursesViewState.error);
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await loadCourses();
  }

  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    if (msg.contains('404') || msg.contains('not found')) {
      return 'No se encontraron cursos matriculados.';
    }
    return 'Error cargando cursos. Intenta de nuevo.';
  }

  void _setState(CoursesViewState newState) {
    _state = newState;
    notifyListeners();
  }
}