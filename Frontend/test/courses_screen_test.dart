import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/core/theme/app_theme.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/data/models/course_model.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/courses_viewmodel.dart';
import 'package:rumbo_app/views/screens/courses_screen.dart';

class FakeApiService extends ApiService {
  @override
  Future<StudentCoursesResponse> getStudentCourses(String studentId) async {
    return getDemoCourses(studentId);
  }
}

void main() {
  Widget createCoursesWidget(CoursesViewModel coursesVm, AuthViewModel authVm) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CoursesViewModel>.value(value: coursesVm),
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CoursesScreen(),
      ),
    );
  }

  testWidgets('CoursesScreen renders header, hero summary card, and course cards', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeApiService();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);

    await tester.pumpWidget(createCoursesWidget(coursesVm, authVm));
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Hola, Valeria'), findsOneWidget);
    expect(find.text('Mis cursos'), findsOneWidget);
    expect(find.text('VQ'), findsOneWidget);

    // Verify hero banner
    expect(
      find.text('1 curso necesita tu atención y 2 conviene revisarlos esta semana.'),
      findsOneWidget,
    );
    expect(find.text('1 crítico'), findsOneWidget);
    expect(find.text('2 en riesgo'), findsOneWidget);
    expect(find.text('1 seguro'), findsOneWidget);
    expect(
      find.text('Son estimaciones basadas en tu actividad en Moodle, no notas.'),
      findsOneWidget,
    );

    // Verify sort & sync row
    expect(find.text('Por prioridad'), findsOneWidget);
    expect(find.text(coursesVm.lastSyncFormatted), findsOneWidget);

    // Verify courses
    expect(find.text('Patrones de Diseño de Software'), findsOneWidget);
    expect(find.text('85 %'), findsOneWidget);

    expect(find.text('Ingeniería de Requisitos'), findsOneWidget);
    expect(find.text('52 %'), findsOneWidget);

    expect(find.text('Arquitectura de Software'), findsOneWidget);
    expect(find.text('41 %'), findsOneWidget);

    expect(find.text('Base de Datos II'), findsOneWidget);
    expect(find.text('18 %'), findsOneWidget);

    expect(find.text('Gestión de Proyectos de Software'), findsOneWidget);
    expect(find.text('Desde el 19 de oct.'), findsOneWidget);
  });

  testWidgets('CoursesScreen toggles sorting between Por prioridad and Alfabético', (tester) async {
    final api = FakeApiService();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);

    await tester.pumpWidget(createCoursesWidget(coursesVm, authVm));
    await tester.pumpAndSettle();

    expect(find.text('Por prioridad'), findsOneWidget);

    // Tap to toggle sort
    await tester.tap(find.text('Por prioridad'));
    await tester.pumpAndSettle();

    expect(find.text('Alfabético'), findsOneWidget);
    expect(coursesVm.sortByPriority, false);
  });

  testWidgets('CoursesScreen displays Empty State correctly', (tester) async {
    final api = FakeApiService();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);

    await tester.pumpWidget(createCoursesWidget(coursesVm, authVm));
    await tester.pumpAndSettle();

    coursesVm.simulateState('empty');
    await tester.pumpAndSettle();

    expect(find.text('Aún no vemos cursos tuyos'), findsOneWidget);
    expect(find.text('Volver a buscar'), findsOneWidget);
    expect(find.text('¿Crees que es un error? Escribe a soporte'), findsOneWidget);
  });

  testWidgets('CoursesScreen displays Error State correctly', (tester) async {
    final api = FakeApiService();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);

    await tester.pumpWidget(createCoursesWidget(coursesVm, authVm));
    await tester.pumpAndSettle();

    coursesVm.simulateState('error');
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tus cursos'), findsOneWidget);
    expect(find.text('Código: 503 · Rumbo API'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Ver la última copia (ayer, 07:30)'), findsOneWidget);
  });
}
