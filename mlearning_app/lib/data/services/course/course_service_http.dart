import 'package:dio/dio.dart';

import 'package:mlearning_early_warning/data/models/course/course_model.dart';
import 'package:mlearning_early_warning/data/services/course/course_service.dart';

/// Implementación HTTP del servicio de cursos.
///
/// Consume:
/// - `GET /estudiantes/{id}/cursos`  → matrículas del estudiante
/// - `GET /cursos/{id}`              → detalle de curso
class CourseServiceHttp implements CourseService {
  final Dio _dio;

  CourseServiceHttp({required Dio dio}) : _dio = dio;

  @override
  Future<List<CourseEnrollment>> getMyCourses(String studentId) async {
    final response = await _dio.get<List<dynamic>>(
      '/estudiantes/$studentId/cursos',
    );

    final data = response.data ?? [];
    return data
        .map((e) => CourseEnrollment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Course> getCourseDetail(String courseId) async {
    final response = await _dio.get<Map<String, dynamic>>('/cursos/$courseId');
    return Course.fromJson(response.data!);
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // Endpoint de búsqueda no implementado en el backend (futuro).
    return const [];
  }
}
