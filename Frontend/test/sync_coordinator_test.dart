import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/data/models/course_model.dart';
import 'package:rumbo_app/data/models/risk_detail_model.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/data/services/sync_coordinator.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/courses_viewmodel.dart';
import 'package:rumbo_app/viewmodels/metacognitive_viewmodel.dart';
import 'package:rumbo_app/viewmodels/riesgo_viewmodel.dart';

class CountingApiService extends ApiService {
  int coursesFetchCount = 0;
  int riskFetchCount = 0;

  @override
  Future<StudentCoursesResponse> getStudentCourses(
    String studentId, {
    bool refresh = false,
  }) async {
    coursesFetchCount++;
    return getDemoCourses(studentId);
  }

  @override
  Future<RiskDetailResponse> getCourseRiskDetail(
    String studentId,
    String courseId, {
    bool refresh = false,
  }) async {
    riskFetchCount++;
    return getDemoRiskDetail(studentId, courseId);
  }
}

void main() {
  group('AppSyncCoordinator tests', () {
    testWidgets('syncAll with activeCourseId updates Riesgo, Courses and Metacognitive ViewModels', (tester) async {
      final api = CountingApiService();
      final authVm = AuthViewModel(apiService: api);
      final coursesVm = CoursesViewModel(apiService: api);
      final riesgoVm = RiesgoViewModel(apiService: api);
      final metaVm = MetacognitiveViewModel(apiService: api);

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
            ChangeNotifierProvider<CoursesViewModel>.value(value: coursesVm),
            ChangeNotifierProvider<RiesgoViewModel>.value(value: riesgoVm),
            ChangeNotifierProvider<MetacognitiveViewModel>.value(value: metaVm),
          ],
          child: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      // Sincronizar desde la pantalla de diagnóstico y factores para un curso
      await AppSyncCoordinator.syncAll(
        capturedContext,
        activeCourseId: 'CUR-001',
        refreshMoodle: true,
      );

      expect(riesgoVm.detail, isNotNull);
      expect(coursesVm.courses, isNotEmpty);
      expect(metaVm.cursos, isNotEmpty);
      expect(api.riskFetchCount, greaterThan(0));
      expect(api.coursesFetchCount, greaterThan(0));
    });

    testWidgets('reloadLocalState updates courses and metacognitive without crashing', (tester) async {
      final api = CountingApiService();
      final authVm = AuthViewModel(apiService: api);
      final coursesVm = CoursesViewModel(apiService: api);
      final metaVm = MetacognitiveViewModel(apiService: api);

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
            ChangeNotifierProvider<CoursesViewModel>.value(value: coursesVm),
            ChangeNotifierProvider<MetacognitiveViewModel>.value(value: metaVm),
          ],
          child: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      await AppSyncCoordinator.reloadLocalState(capturedContext);

      expect(coursesVm.courses, isNotEmpty);
      expect(metaVm.cursos, isNotEmpty);
    });
  });
}
