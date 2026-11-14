import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo_app/main.dart' as app;
import 'package:rumbo_app/views/widgets/course_card.dart';
import 'package:rumbo_app/views/widgets/liquid_glass_nav_bar.dart';

/// Pausas (en milisegundos) para que se alcance a ver cada paso en Chrome.
/// Si quieres que las pruebas vayan más rápido, baja estos valores.
const int pausaCorta = 500;
const int pausaMedia = 900;

// ---------------------------------------------------------------------------
// Elementos de la pantalla de login
// ---------------------------------------------------------------------------
Finder get campoUsuario => find.widgetWithText(TextField, 'Usuario Moodle');
Finder get campoPassword => find.widgetWithText(TextField, 'Contraseña');
Finder get botonIngresar => find.widgetWithText(FilledButton, 'Iniciar Sesión');

// ---------------------------------------------------------------------------
// Esperas y pausas
// ---------------------------------------------------------------------------

/// Deja pasar un tiempo real para que el ojo humano vea lo que ocurre.
Future<void> pausa(WidgetTester tester, [int ms = pausaCorta]) async {
  await tester.pump(Duration(milliseconds: ms));
}

/// Espera hasta que aparezca [finder]. Falla si no aparece a tiempo.
Future<void> esperar(
  WidgetTester tester,
  Finder finder, {
  int segundos = 30,
}) async {
  final limite = DateTime.now().add(Duration(seconds: segundos));
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Tiempo agotado ($segundos s) esperando: ${finder.description}');
}

/// Espera hasta que aparezca cualquiera de los [finders] y devuelve el que apareció.
Future<Finder> esperarAlguno(
  WidgetTester tester,
  List<Finder> finders, {
  int segundos = 30,
}) async {
  final limite = DateTime.now().add(Duration(seconds: segundos));
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (final f in finders) {
      if (f.evaluate().isNotEmpty) return f;
    }
  }
  fail('Tiempo agotado ($segundos s) esperando alguno de: '
      '${finders.map((f) => f.description).join(' | ')}');
}

/// Espera hasta que [finder] deje de estar en pantalla.
Future<void> esperarQueDesaparezca(
  WidgetTester tester,
  Finder finder, {
  int segundos = 45,
}) async {
  final limite = DateTime.now().add(Duration(seconds: segundos));
  while (finder.evaluate().isNotEmpty) {
    if (!DateTime.now().isBefore(limite)) {
      fail('Tiempo agotado ($segundos s): sigue en pantalla ${finder.description}');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
}

// ---------------------------------------------------------------------------
// Acciones básicas
// ---------------------------------------------------------------------------

/// Toca un elemento (lo desplaza a la vista si hace falta).
Future<void> tocar(WidgetTester tester, Finder finder) async {
  final objetivo = finder.first;
  await tester.ensureVisible(objetivo);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(objetivo);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Desplaza hacia abajo la pantalla actual hasta que [finder] sea visible.
Future<void> verAbajoHasta(WidgetTester tester, Finder finder) async {
  if (finder.hitTestable().evaluate().isNotEmpty) return;
  final scrollVertical = find
      .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
      .first;
  await tester.scrollUntilVisible(
    finder.first,
    350,
    scrollable: scrollVertical,
    maxScrolls: 40,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Cambia entre modo claro y modo oscuro con el botón de la barra superior.
Future<void> alternarTema(WidgetTester tester) async {
  final oscuro = find.byTooltip('Modo oscuro');
  final claro = find.byTooltip('Modo claro');
  final boton = oscuro.evaluate().isNotEmpty ? oscuro : claro;
  await tocar(tester, boton);
  await pausa(tester, 700);
}

// ---------------------------------------------------------------------------
// Flujos reutilizables
// ---------------------------------------------------------------------------

/// Abre la app desde cero y espera a ver la pantalla de login.
Future<void> abrirApp(WidgetTester tester) async {
  app.main();
  await esperar(tester, campoUsuario);
  await pausa(tester, 600);
}

/// Inicia sesión con la cuenta DEMO y espera a que carguen los cursos.
Future<void> iniciarSesionDemo(WidgetTester tester) async {
  await abrirApp(tester);
  await tocar(tester, find.widgetWithText(ActionChip, 'Modo Demo'));
  await tocar(tester, botonIngresar);
  await esperar(tester, find.text('Mis Cursos'), segundos: 40);
  await esperar(tester, find.byType(CourseCard), segundos: 40);
  await pausa(tester, 800);
}

/// Cambia a una pestaña de la barra inferior: 'Asignaturas', 'Tutor IA',
/// 'Métricas' o 'Logros'.
Future<void> irAPestana(WidgetTester tester, String etiqueta) async {
  final item = find.descendant(
    of: find.byType(LiquidGlassNavBar).first,
    matching: find.text(etiqueta),
  );
  await tocar(tester, item);
  await pausa(tester, 700);
}

/// Abre el diagnóstico del primer curso que sí tenga estimación de riesgo
/// (algunos cursos aparecen como "Sin estimación").
Future<void> abrirCursoConEstimacion(WidgetTester tester) async {
  final botonPorQue = find.text('¿Por qué este resultado?');
  final sinEstimacion = find.text('Abrir curso en Moodle');
  final total = find.byType(CourseCard).evaluate().length;

  for (var i = 0; i < total; i++) {
    await tocar(tester, find.byType(CourseCard).at(i));
    await esperar(tester, find.text('Diagnóstico de Riesgo'));
    final aparecio = await esperarAlguno(tester, [botonPorQue, sinEstimacion]);
    if (aparecio == botonPorQue) {
      await pausa(tester, 800);
      return;
    }
    await tester.pageBack();
    await pausa(tester, 700);
  }
  fail('Ningún curso del usuario DEMO tiene estimación de riesgo.');
}
