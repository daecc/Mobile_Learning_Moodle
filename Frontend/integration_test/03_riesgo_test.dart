import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rumbo_app/views/widgets/risk_gauge.dart';

import 'helpers.dart';

/// Ventana 3 · Diagnóstico de Riesgo
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 3 · Diagnóstico de Riesgo', () {
    testWidgets('3.1 La barra superior muestra "Diagnóstico de Riesgo"',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      expect(find.text('Diagnóstico de Riesgo'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('3.2 Muestra el medidor con el porcentaje de riesgo',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      expect(find.byType(RiskGauge), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('3.3 Muestra el rango probable del riesgo', (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      expect(find.textContaining('Rango probable'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('3.4 Muestra los botones de acción principales', (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      expect(find.text('¿Por qué este resultado?'), findsOneWidget);
      expect(find.text('Ir a Moodle'), findsOneWidget);
      await verAbajoHasta(tester, find.text('Consultar con Tutor IA'));
      expect(find.text('Consultar con Tutor IA'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('3.5 "Ir a Moodle" abre la ventana con la dirección del aula',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      await tocar(tester, find.text('Ir a Moodle'));
      await pausa(tester, pausaMedia);

      expect(find.text('Aula Virtual MoodleCloud'), findsOneWidget);
      expect(
        find.text('https://rumbo-mobile-learning.moodlecloud.com'),
        findsOneWidget,
      );

      await tocar(tester, find.text('Abrir Moodle'));
      await pausa(tester, pausaMedia);
      expect(find.text('Aula Virtual MoodleCloud'), findsNothing);
    });

    testWidgets('3.6 El botón de tema cambia entre claro y oscuro',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      expect(find.byTooltip('Modo oscuro'), findsWidgets);
      await alternarTema(tester);
      expect(find.byTooltip('Modo claro'), findsWidgets);
      await pausa(tester, pausaMedia);

      // Se devuelve al modo claro para no afectar a las demás pruebas.
      await alternarTema(tester);
      expect(find.byTooltip('Modo oscuro'), findsWidgets);
    });

    testWidgets('3.7 "Recalcular diagnóstico" mantiene la pantalla estable',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      await tocar(tester, find.byTooltip('Recalcular diagnóstico'));
      await pausa(tester, 1500);
      await esperar(tester, find.text('¿Por qué este resultado?'));

      expect(find.text('Diagnóstico de Riesgo'), findsOneWidget);
    });

    testWidgets('3.8 "Consultar con Tutor IA" abre el tutor del curso',
        (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      await tocar(tester, find.text('Consultar con Tutor IA'));
      await esperar(tester, find.text('Tutor Inteligente IA'));

      expect(find.text('Tutor Inteligente IA'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('3.9 La flecha de regreso vuelve a Mis Cursos', (tester) async {
      await iniciarSesionDemo(tester);
      await abrirCursoConEstimacion(tester);

      await tester.pageBack();
      await esperar(tester, find.text('Mis Cursos'));
      await pausa(tester, 1000); // termina la animación de salida

      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(find.text('Diagnóstico de Riesgo'), findsNothing);
      await pausa(tester, pausaMedia);
    });
  });
}
