import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/data/models/risk_detail_model.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/riesgo_viewmodel.dart';
import 'package:rumbo_app/views/screens/factors_screen.dart';
import 'package:rumbo_app/views/widgets/factor_charts/day_circles_chart.dart';
import 'package:rumbo_app/views/widgets/factor_charts/quiz_trend_chart.dart';
import 'package:rumbo_app/views/widgets/factor_charts/tasks_timeline_chart.dart';
import 'package:rumbo_app/views/widgets/factor_charts/weekly_logins_chart.dart';

class FakeFactorsApiService extends ApiService {
  @override
  Future<RiskDetailResponse> getCourseRiskDetail(String studentId, String courseId) async {
    return getDemoRiskDetail(studentId, courseId);
  }
}

Widget createFactorsWidget(
  RiesgoViewModel riesgoVm,
  AuthViewModel authVm,
  String courseId,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RiesgoViewModel>.value(value: riesgoVm),
      ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
    ],
    child: MaterialApp(
      home: FactorsScreen(courseId: courseId),
    ),
  );
}

void main() {
  testWidgets('FactorsScreen renders full mock for Patrones de Diseño (85%)', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeFactorsApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createFactorsWidget(riesgoVm, authVm, 'CUR-001'));
    await tester.pumpAndSettle();

    // 1. Header & Course Title
    expect(find.text('¿Por qué 85 %?'), findsOneWidget);
    expect(find.text('Patrones de Diseño de Software'), findsOneWidget);

    // 2. Summary Hero Card
    expect(find.textContaining('últimas 4 semanas'), findsOneWidget);
    expect(find.text('4 suman al riesgo'), findsOneWidget);
    expect(find.text('2 juegan a tu favor'), findsOneWidget);
    expect(
      find.text('Todo esto depende de hábitos que puedes cambiar: si cambian, la estimación también.'),
      findsOneWidget,
    );

    // 3. Section: Lo que más suma al riesgo
    expect(find.text('Lo que más suma al riesgo'), findsOneWidget);

    // Factor 1: Inactividad
    expect(find.text('Llevas 5 días sin entrar al curso'), findsOneWidget);
    expect(find.text('Antes entrabas cada 2 días, en promedio.'), findsOneWidget);
    expect(find.byType(DayCirclesChart), findsOneWidget);

    // Factor 2: Cuestionarios
    expect(find.text('Tu promedio en los últimos 3 cuestionarios es 11/20'), findsOneWidget);
    expect(find.text('Empezaste con 14 y ha ido bajando de a poco.'), findsOneWidget);
    expect(find.byType(QuizTrendChart), findsOneWidget);

    // Factor 3: Tareas pendientes
    expect(find.text('Tienes 2 tareas pendientes'), findsOneWidget);
    expect(find.text('Entregaste 3 de 5. La Tarea 4 vence el viernes 16.'), findsOneWidget);
    expect(find.byType(TasksTimelineChart), findsOneWidget);

    // Factor 4: Frecuencia de acceso semanal
    expect(find.text('Esta semana entraste 1 vez'), findsOneWidget);
    expect(find.text('La mayoría de tu sección entra unas 4 veces por semana.'), findsOneWidget);
    expect(find.byType(WeeklyLoginsChart), findsOneWidget);

    // 4. Section: Lo que juega a tu favor
    expect(find.text('Lo que juega a tu favor'), findsOneWidget);
    expect(find.text('Sacaste 14/20 en el examen parcial'), findsOneWidget);
    expect(find.text('Demuestra que entiendes la base del curso.'), findsOneWidget);
    expect(find.text('Entregaste a tiempo tus 3 primeras tareas'), findsOneWidget);

    // 5. Metacognitive Reflection Section
    expect(find.text('¿Qué te está costando más?'), findsOneWidget);
    expect(find.text('Organizar mi tiempo'), findsOneWidget);
    await tester.tap(find.text('Organizar mi tiempo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Reflexión guardada localmente'), findsOneWidget);

    // 6. H3 Control: Cuestionar datos
    expect(find.text('¿Algún dato no cuadra? Cuestionar datos de la IA'), findsOneWidget);
    await tester.tap(find.text('¿Algún dato no cuadra? Cuestionar datos de la IA'));
    await tester.pumpAndSettle();
    expect(find.text('¿Algún dato no cuadra?'), findsOneWidget);
    expect(find.text('Ya entregué una tarea que figura pendiente'), findsOneWidget);

    // 7. Sticky Bottom Button
    expect(find.text('Abrir curso en Moodle'), findsOneWidget);
  });

  testWidgets('FactorsScreen renders Base de Datos II (Seguro, 18%)', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeFactorsApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createFactorsWidget(riesgoVm, authVm, 'CUR-004'));
    await tester.pumpAndSettle();

    expect(find.text('¿Por qué 18 %?'), findsOneWidget);
    expect(find.text('Base de Datos II'), findsOneWidget);
    expect(find.text('1 suman al riesgo'), findsOneWidget);
    expect(find.text('4 juegan a tu favor'), findsOneWidget);
    expect(find.text('Tu promedio en cuestionarios es 17/20'), findsOneWidget);
    expect(find.text('Has completado el 100% de entregas'), findsOneWidget);
  });

  testWidgets('FactorsScreen renders Gestión de Proyectos (Sin estimación)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeFactorsApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createFactorsWidget(riesgoVm, authVm, 'CUR-005'));
    await tester.pumpAndSettle();

    expect(find.text('Sin estimación'), findsOneWidget);
    expect(find.text('Gestión de Proyectos de Software'), findsOneWidget);
    expect(find.text('Sin factores calculados aún'), findsOneWidget);
  });
}
