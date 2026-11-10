import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
import '../../viewmodels/riesgo_viewmodel.dart';

/// Coordinador centralizado de sincronización de estado y datos Moodle.
///
/// Garantiza que cuando una pantalla refresca sus datos, TODAS las demás
/// pantallas (Mis Cursos, Diagnóstico de Riesgo y Factores, Control Metacognitivo)
/// se actualicen de manera coherente y simultánea sin requerir refrescos manuales
/// redundantes en cada vista.
class AppSyncCoordinator {
  AppSyncCoordinator._();

  /// Sincroniza todas las vistas cuando el usuario refresca en cualquier pantalla.
  ///
  /// - [refreshMoodle]: Si es true, contacta al servidor MoodleCloud para re-calcular variables.
  /// - [activeCourseId]: Si se provee, prioriza la actualización de ese curso en particular
  ///   y de inmediato refresca los cursos generales y las métricas metacognitivas.
  static Future<void> syncAll(
    BuildContext context, {
    bool refreshMoodle = true,
    String? activeCourseId,
  }) async {
    try {
      final authStudent = context.read<AuthViewModel?>()?.student;
      final coursesVm = context.read<CoursesViewModel?>();
      final riesgoVm = context.read<RiesgoViewModel?>();
      final metaVm = context.read<MetacognitiveViewModel?>();

      final studentId = authStudent?.idEstudiante ?? coursesVm?.studentId ?? 'EST-0001';
      final courseId = activeCourseId ?? riesgoVm?.courseId;

      if (courseId != null && courseId.isNotEmpty && riesgoVm != null) {
        // 1. Sincroniza el detalle del curso con MoodleCloud
        await riesgoVm.loadDetail(
          courseId,
          studentId: studentId,
          refresh: refreshMoodle,
        );
        // 2. Con la base de datos local actualizada, recarga cursos de inmediato sin re-contactar Moodle
        if (coursesVm != null) {
          await coursesVm.loadCourses(
            studentId: studentId,
            refresh: false,
          );
        }
      } else if (coursesVm != null) {
        // 1. Sincroniza la lista de todos los cursos con MoodleCloud
        await coursesVm.loadCourses(
          studentId: studentId,
          refresh: refreshMoodle,
        );
        // 2. Si hay un curso activo en riesgoVm, actualiza también su detalle desde SQLite
        if (riesgoVm != null && riesgoVm.courseId != null && riesgoVm.courseId!.isNotEmpty) {
          await riesgoVm.loadDetail(
            riesgoVm.courseId!,
            studentId: studentId,
            refresh: false,
          );
        }
      }

      // 3. Actualiza siempre el panel de control metacognitivo con los cursos frescos
      if (metaVm != null && coursesVm != null && coursesVm.courses.isNotEmpty) {
        await metaVm.load(
          coursesVm.courses,
          studentId,
          refresh: false,
        );
      }
    } catch (_) {
      // Ignorar excepciones de coordinación para no interferir con la UI
    }
  }

  /// Recarga en memoria sin golpear a Moodle (rápido, <20ms desde SQLite)
  /// para cuando el usuario regresa a una pantalla o cambia de pestaña.
  static Future<void> reloadLocalState(BuildContext context) async {
    try {
      final authStudent = context.read<AuthViewModel?>()?.student;
      final coursesVm = context.read<CoursesViewModel?>();
      final metaVm = context.read<MetacognitiveViewModel?>();
      final studentId = authStudent?.idEstudiante ?? coursesVm?.studentId ?? 'EST-0001';

      if (coursesVm != null) {
        await coursesVm.loadCourses(
          studentId: studentId,
          refresh: false,
        );
      }

      if (metaVm != null && coursesVm != null && coursesVm.courses.isNotEmpty) {
        await metaVm.load(
          coursesVm.courses,
          studentId,
          refresh: false,
        );
      }
    } catch (_) {
      // Ignorar excepciones de coordinación
    }
  }
}
