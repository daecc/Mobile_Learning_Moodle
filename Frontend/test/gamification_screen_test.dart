import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/core/theme/app_theme.dart';
import 'package:rumbo_app/data/models/course_model.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/courses_viewmodel.dart';
import 'package:rumbo_app/viewmodels/metacognitive_viewmodel.dart';
import 'package:rumbo_app/viewmodels/theme_viewmodel.dart';
import 'package:rumbo_app/viewmodels/tutor_viewmodel.dart';
import 'package:rumbo_app/views/screens/gamification_screen.dart';

import 'package:rumbo_app/data/models/gamification_tier.dart';
import 'package:rumbo_app/views/widgets/tier_avatar.dart';
import 'package:rumbo_app/data/models/risk_detail_model.dart';

class FakeGamificationApi extends ApiService {
  final List<String> fakeRecordedReviews = [];

  @override
  Future<StudentCoursesResponse> getStudentCourses(
      String studentId, {bool refresh = false}) async {
    return getDemoCourses(studentId);
  }

  @override
  Future<DiagnosticReviewsResult> getDiagnosticReviews(String studentId) async {
    return DiagnosticReviewsResult(
      cursosRevisados: List.from(fakeRecordedReviews),
      semanasPreviasCompletadas: 0,
    );
  }

  @override
  Future<DiagnosticReviewsResult> recordDiagnosticReview(String studentId, String courseId) async {
    if (!fakeRecordedReviews.contains(courseId)) {
      fakeRecordedReviews.add(courseId);
    }
    return DiagnosticReviewsResult(
      cursosRevisados: List.from(fakeRecordedReviews),
      semanasPreviasCompletadas: 0,
    );
  }
}

class MockMetacognitiveViewModel extends MetacognitiveViewModel {
  MockMetacognitiveViewModel({required super.apiService});

  List<CourseMetacognitive> customCursos = [];
  Set<String> customCursosRevisados = {};

  @override
  List<CourseMetacognitive> get cursos => customCursos;

  @override
  Set<String> get cursosRevisadosEstaSemana => customCursosRevisados;
}

class MockCoursesViewModel extends CoursesViewModel {
  MockCoursesViewModel({required super.apiService});

  List<CourseRiskSummary> customCourses = [];

  @override
  List<CourseRiskSummary> get courses => customCourses;
}

void main() {
  Widget buildGamificationApp({
    required CoursesViewModel coursesVm,
    required AuthViewModel authVm,
    required MetacognitiveViewModel metaVm,
    required TutorViewModel tutorVm,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CoursesViewModel>.value(value: coursesVm),
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider<MetacognitiveViewModel>.value(value: metaVm),
        ChangeNotifierProvider<TutorViewModel>.value(value: tutorVm),
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const GamificationScreen(isTab: true),
      ),
    );
  }

  testWidgets('GamificationScreen renders menu button, rules button, XP on all cards and opens rules modal and drawer', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify title and XP points on achievement cards
    expect(find.text('Gamificación'), findsOneWidget);
    expect(find.text('+100 XP'), findsWidgets);
    expect(find.text('+150 XP'), findsWidgets);

    // 2. Verify rules button is present and opens rules modal
    final helpBtn = find.byTooltip('Reglas del juego y recompensas');
    expect(helpBtn, findsOneWidget);
    await tester.tap(helpBtn);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Reglas y Recompensas'), findsOneWidget);
    expect(find.text('1. ¿Cómo sumar Puntos Rumbo (XP)?'), findsOneWidget);
    expect(find.text('+50 XP'), findsWidgets);
    expect(find.textContaining('2. Niveles de Maestría y Rangos'), findsOneWidget);
    expect(find.text('Explorador Inicial'), findsWidgets);

    // Close rules modal cleanly
    Navigator.of(tester.element(find.text('Reglas y Recompensas'))).pop();
    await tester.pump(const Duration(milliseconds: 600));

    // 3. Verify menu hamburger button opens AppDrawer
    final menuBtn = find.byTooltip('Menú de opciones');
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Cerrar Sesión'), findsOneWidget);
  });

  testWidgets('As de los Cuestionarios muestra mensaje por defecto si no hay notas', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('As de los Cuestionarios'), findsOneWidget);
    expect(find.text('Obtén promedio ponderado destacado (≥ 14.0) en tus cuestionarios de Moodle.'), findsOneWidget);
  });

  testWidgets('As de los Cuestionarios calcula promedio ponderado y se bloquea si es menor a 14.0', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    // Curso 1: nota 6.5, 4 créditos
    metaVm.customCursos = [
      const CourseMetacognitive(
        curso: CourseRiskSummary(
          idCurso: '1',
          nombreCurso: 'Estructuras Discretas',
          codigoCurso: 'ED101',
          creditos: 4,
          docente: 'Profesor X',
          probabilidadRiesgo: 0.8,
          porcentajeRiesgo: 80,
          nivelRiesgo: 'CRITICO',
        ),
        metricas: [
          MetacognitiveStat(
            clave: 'promedio',
            titulo: 'Promedio de Evaluaciones',
            valor: '6.5',
            estado: 'critico',
            descripcion: 'Promedio bajo',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('As de los Cuestionarios'), findsOneWidget);
    expect(
      find.text('Requiere promedio ponderado destacado (≥ 14.0) en cuestionarios (Tu promedio ponderado actual: 6.5/20).'),
      findsOneWidget,
    );
  });

  testWidgets('As de los Cuestionarios se desbloquea con promedio ponderado >= 14.0 considerando créditos', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    // Curso 1: nota 16.0, 4 créditos (ponderado: 64)
    // Curso 2: nota 14.0, 4 créditos (ponderado: 56)
    // Total: (64 + 56) / 8 = 120 / 8 = 15.0
    metaVm.customCursos = [
      const CourseMetacognitive(
        curso: CourseRiskSummary(
          idCurso: '1',
          nombreCurso: 'Física I',
          codigoCurso: 'FIS101',
          creditos: 4,
          docente: 'Profesor A',
          probabilidadRiesgo: 0.1,
          porcentajeRiesgo: 10,
          nivelRiesgo: 'BAJO',
        ),
        metricas: [
          MetacognitiveStat(
            clave: 'promedio',
            titulo: 'Promedio',
            valor: '16.0',
            estado: 'ok',
            descripcion: 'Promedio sobresaliente',
          ),
        ],
      ),
      const CourseMetacognitive(
        curso: CourseRiskSummary(
          idCurso: '2',
          nombreCurso: 'Cálculo I',
          codigoCurso: 'MAT102',
          creditos: 4,
          docente: 'Profesor B',
          probabilidadRiesgo: 0.2,
          porcentajeRiesgo: 20,
          nivelRiesgo: 'BAJO',
        ),
        metricas: [
          MetacognitiveStat(
            clave: 'promedio',
            titulo: 'Promedio',
            valor: '14.0',
            estado: 'ok',
            descripcion: 'Promedio aprobatorio',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('As de los Cuestionarios'), findsOneWidget);
    expect(
      find.text('¡Meta lograda! Promedio ponderado destacado en cuestionarios (15.0/20 en el ciclo).'),
      findsOneWidget,
    );
  });

  testWidgets('Constancia Semanal evalúa días activos reales y permanece bloqueado con 2 de 4 días', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    // Estudiante ingresó 2 días frente a la meta recomendada de 4 días: [2.0, 4.0]
    metaVm.customCursos = [
      const CourseMetacognitive(
        curso: CourseRiskSummary(
          idCurso: '1',
          nombreCurso: 'Física I',
          codigoCurso: 'FIS101',
          creditos: 4,
          docente: 'Profesor A',
          probabilidadRiesgo: 0.2,
          porcentajeRiesgo: 20,
          nivelRiesgo: 'BAJO',
        ),
        accesosSemanales: [2.0, 4.0],
      ),
    ];

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Constancia Semanal'), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);
    expect(
      find.text('Cumple la meta recomendada de 4 días de actividad semanal en el aula virtual (2 de 4 días).'),
      findsOneWidget,
    );
  });

  testWidgets('Constancia Semanal se desbloquea al cumplir 4 o más días de actividad', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    // Estudiante ingresó 4 días frente a la meta recomendada de 4 días: [4.0, 4.0]
    metaVm.customCursos = [
      const CourseMetacognitive(
        curso: CourseRiskSummary(
          idCurso: '1',
          nombreCurso: 'Física I',
          codigoCurso: 'FIS101',
          creditos: 4,
          docente: 'Profesor A',
          probabilidadRiesgo: 0.1,
          porcentajeRiesgo: 10,
          nivelRiesgo: 'BAJO',
        ),
        accesosSemanales: [4.0, 4.0],
      ),
    ];

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Constancia Semanal'), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
    expect(
      find.text('¡Meta lograda! Cumples con la meta recomendada de 4 días de actividad semanal (4 de 4 días).'),
      findsOneWidget,
    );
  });

  testWidgets('Estratega del Aprendizaje permanece bloqueado si solo se revisaron algunos cursos', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = MockCoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    coursesVm.customCourses = const [
      CourseRiskSummary(
        idCurso: '1',
        nombreCurso: 'Cálculo I',
        codigoCurso: 'MAT101',
        creditos: 4,
        docente: 'Profesor A',
        probabilidadRiesgo: 0.1,
        porcentajeRiesgo: 10,
        nivelRiesgo: 'BAJO',
      ),
      CourseRiskSummary(
        idCurso: '2',
        nombreCurso: 'Física I',
        codigoCurso: 'FIS101',
        creditos: 4,
        docente: 'Profesor B',
        probabilidadRiesgo: 0.3,
        porcentajeRiesgo: 30,
        nivelRiesgo: 'BAJO',
      ),
    ];

    // Solo revisó 1 de 2 cursos esta semana
    metaVm.customCursosRevisados = {'1'};

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Estratega del Aprendizaje'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(
      find.text('Revisa el diagnóstico detallado («¿Por qué este resultado?») de cada curso (1 de 2 revisados esta semana).'),
      findsOneWidget,
    );
  });

  testWidgets('Estratega del Aprendizaje se desbloquea al presionar y revisar todos los cursos esta semana', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = MockCoursesViewModel(apiService: api);
    final metaVm = MockMetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    coursesVm.customCourses = const [
      CourseRiskSummary(
        idCurso: '1',
        nombreCurso: 'Cálculo I',
        codigoCurso: 'MAT101',
        creditos: 4,
        docente: 'Profesor A',
        probabilidadRiesgo: 0.1,
        porcentajeRiesgo: 10,
        nivelRiesgo: 'BAJO',
      ),
      CourseRiskSummary(
        idCurso: '2',
        nombreCurso: 'Física I',
        codigoCurso: 'FIS101',
        creditos: 4,
        docente: 'Profesor B',
        probabilidadRiesgo: 0.3,
        porcentajeRiesgo: 30,
        nivelRiesgo: 'BAJO',
      ),
    ];

    // Revisó los 2 cursos esta semana
    metaVm.customCursosRevisados = {'1', '2'};

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Estratega del Aprendizaje'), findsOneWidget);
    expect(find.text('2/2'), findsWidgets);
    expect(
      find.text('¡Meta lograda! Has revisado el diagnóstico predictivo de todos tus cursos (2 de 2 revisados esta semana).'),
      findsOneWidget,
    );
  });

  test('MetacognitiveViewModel registra revision de diagnostico sin duplicar', () {
    final api = FakeGamificationApi();
    final metaVm = MetacognitiveViewModel(apiService: api);

    expect(metaVm.cursosRevisadosEstaSemana.isEmpty, isTrue);

    metaVm.registrarRevisionDiagnostico('curso_101');
    expect(metaVm.cursosRevisadosEstaSemana.length, 1);
    expect(metaVm.cursosRevisadosEstaSemana.contains('curso_101'), isTrue);

    // Si se presiona nuevamente en el mismo curso, no duplica
    metaVm.registrarRevisionDiagnostico('curso_101');
    expect(metaVm.cursosRevisadosEstaSemana.length, 1);

    metaVm.registrarRevisionDiagnostico('curso_102');
    expect(metaVm.cursosRevisadosEstaSemana.length, 2);
  });

  test('MetacognitiveViewModel persiste y recupera revisiones de diagnostico via API', () async {
    final api = FakeGamificationApi();
    api.fakeRecordedReviews.addAll(['curso_A', 'curso_B']);
    final metaVm = MetacognitiveViewModel(apiService: api);

    await metaVm.load([], 'EST-0001');

    expect(metaVm.cursosRevisadosEstaSemana.length, 2);
    expect(metaVm.cursosRevisadosEstaSemana.contains('curso_A'), isTrue);
    expect(metaVm.cursosRevisadosEstaSemana.contains('curso_B'), isTrue);
  });

  test('GamificationTier asigna correctamente los 6 rangos adaptados a las 14 semanas', () {
    expect(GamificationTier.fromXp(0).level, 1);
    expect(GamificationTier.fromXp(350).title, 'Explorador Inicial');

    expect(GamificationTier.fromXp(400).level, 2);
    expect(GamificationTier.fromXp(850).title, 'Estudiante Constante');

    expect(GamificationTier.fromXp(900).level, 3);
    expect(GamificationTier.fromXp(1200).title, 'Estratega Académico');

    expect(GamificationTier.fromXp(1500).level, 4);
    expect(GamificationTier.fromXp(2000).title, 'Mentor Destacado');

    expect(GamificationTier.fromXp(2200).level, 5);
    expect(GamificationTier.fromXp(2800).title, 'Maestro del Ciclo');

    expect(GamificationTier.fromXp(3000).level, 6);
    expect(GamificationTier.fromXp(4500).title, 'Leyenda de San Marcos');
  });

  test('GamificationPointsSummary calcula acumulador acumulando semanas previas sin restar XP', () {
    // Escenario: Semana 5 de ciclo
    // 5 tareas entregadas (250 XP), 3 cursos en zona segura (300 XP),
    // 2 semanas previas con Estratega completado (180 XP), 3 semanas con racha Constancia (240 XP),
    // y logro Entrega Impecable (+100 XP)
    final summary = GamificationPointsSummary.calculate(
      tareasEntregadas: 5,
      safeCourses: 3,
      totalCursos: 3,
      tareasTotales: 5,
      tieneBuenPromedio: false,
      diasActivosSemanales: 2, // No cumplio constancia esta semana
      esEstrategaEstaSemana: false, // No reviso esta semana
      semanasPreviasEstratega: 2,
      semanasPreviasConstancia: 3,
      tutorConsultas: 0,
    );

    // 250 (tareas) + 300 (seguros) + 100 (entrega impecable) + 150 (guardian)
    // + 0 (constancia actual) + 240 (constancia previa)
    // + 0 (estratega actual) + 180 (estratega previo)
    // Total = 1220 XP -> Nivel 3 (Estratega Academico)
    expect(summary.totalPoints, 1220);
    expect(summary.tier.level, 3);
    expect(summary.tier.title, 'Estratega Académico');
  });

  testWidgets('TierAvatar renderiza marco cosmetico y distintivo de rango correctamente', (tester) async {
    final tier = GamificationTier.fromXp(1600); // Nivel 4: Mentor Destacado
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: TierAvatar(
              initials: 'CR',
              tier: tier,
              radius: 36,
              showBadge: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('CR'), findsOneWidget);
    expect(find.text('Nivel 4 · Mentor Destacado'), findsOneWidget);
  });

  testWidgets('Mente Inquisitiva muestra texto dinamico con progreso de consultas', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaintingBinding.instance.imageCache.clear();
    });

    final api = FakeGamificationApi();
    final authVm = AuthViewModel(apiService: api);
    final coursesVm = CoursesViewModel(apiService: api);
    final metaVm = MetacognitiveViewModel(apiService: api);
    final tutorVm = TutorViewModel(apiService: api);

    await tester.pumpWidget(buildGamificationApp(
      coursesVm: coursesVm,
      authVm: authVm,
      metaVm: metaVm,
      tutorVm: tutorVm,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mente Inquisitiva'), findsOneWidget);
    expect(find.text('Realiza consultas reflexivas con el Tutor Inteligente IA (0 de 3 consultas realizadas).'), findsOneWidget);
  });
}
