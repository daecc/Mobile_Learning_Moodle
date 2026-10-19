import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/core/theme/app_theme.dart';
import 'package:rumbo_app/data/models/risk_detail_model.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/riesgo_viewmodel.dart';
import 'package:rumbo_app/viewmodels/theme_viewmodel.dart';
import 'package:rumbo_app/views/screens/risk_screen.dart';

class FakeRiskApiService extends ApiService {
  @override
  Future<RiskDetailResponse> getCourseRiskDetail(
      String studentId, String courseId, {bool refresh = false}) async {
    return getDemoRiskDetail(studentId, courseId);
  }
}

void main() {
  Widget createRiskWidget(RiesgoViewModel riesgoVm, AuthViewModel authVm, String courseId) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RiesgoViewModel>.value(value: riesgoVm),
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: RiskScreen(courseId: courseId),
      ),
    );
  }

  testWidgets('RiskScreen renders Base de Datos II (Seguro, 18%)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeRiskApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createRiskWidget(riesgoVm, authVm, 'CUR-004'));
    await tester.pumpAndSettle();

    // Verify course header
    expect(find.text('Base de Datos II'), findsOneWidget);
    expect(find.text('Actualizado hoy, 07:30 · se recalcula a diario'), findsOneWidget);

    // Verify top green banner
    expect(find.text('Vas por buen camino en este curso.'), findsOneWidget);

    // Verify percentage & range
    expect(find.text('18 %'), findsOneWidget);
    expect(find.text('Seguro'), findsWidgets);
    expect(find.textContaining('11–27 %'), findsOneWidget);

    // Verify next step
    expect(find.text('Para mantener el ritmo'), findsOneWidget);
    expect(find.text('Cuestionario 4: Normalización'), findsOneWidget);
    expect(find.text('Se abre el miércoles 14 de octubre'), findsOneWidget);

    // Verify bottom actions
    expect(find.text('¿Por qué este resultado?'), findsOneWidget);
    expect(find.text('Ir a Moodle'), findsOneWidget);
  });

  testWidgets('RiskScreen renders Ingeniería de Requisitos (En riesgo, 52%)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeRiskApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createRiskWidget(riesgoVm, authVm, 'CUR-002'));
    await tester.pumpAndSettle();

    expect(find.text('Ingeniería de Requisitos'), findsOneWidget);
    expect(find.text('Hay algunas señales que conviene atender.'), findsOneWidget);
    expect(find.text('52 %'), findsOneWidget);
    expect(find.text('En riesgo'), findsWidgets);
    expect(find.textContaining('44–60 %'), findsOneWidget);
    expect(find.text('Qué puedes hacer ahora'), findsOneWidget);
    expect(find.text('Entrega la Tarea 2: Casos de uso'), findsOneWidget);
  });

  testWidgets('RiskScreen renders Patrones de Diseño (Crítico, 85%)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeRiskApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createRiskWidget(riesgoVm, authVm, 'CUR-001'));
    await tester.pumpAndSettle();

    expect(find.text('Patrones de Diseño de Software'), findsOneWidget);
    expect(find.text('ALERTA TEMPRANA'), findsOneWidget);
    expect(find.text('Detectamos señales de riesgo. Aún estás a tiempo de mejorar.'), findsOneWidget);
    expect(find.text('85 %'), findsOneWidget);
    expect(find.text('Riesgo crítico'), findsWidgets);
    expect(find.textContaining('78–91 %'), findsOneWidget);
    expect(find.text('Entrega la Tarea 4: Patrón Observer'), findsOneWidget);
  });

  testWidgets('RiskScreen renders Gestión de Proyectos (Sin estimación todavía)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = FakeRiskApiService();
    final authVm = AuthViewModel(apiService: api);
    final riesgoVm = RiesgoViewModel(apiService: api);

    await tester.pumpWidget(createRiskWidget(riesgoVm, authVm, 'CUR-005'));
    await tester.pumpAndSettle();

    expect(find.text('Gestión de Proyectos de Software'), findsOneWidget);
    expect(find.text('Revisado hoy, 07:30'), findsOneWidget);
    expect(find.text('Sin estimación todavía'), findsOneWidget);
    expect(find.text('Aún no hay suficiente actividad para estimar'), findsOneWidget);
    expect(find.text('Datos reunidos'), findsOneWidget);
    expect(find.text('Semana 1 de 2'), findsOneWidget);
    expect(find.text('Abrir curso en Moodle'), findsOneWidget);
  });
}
