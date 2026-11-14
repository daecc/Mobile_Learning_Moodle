import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 4 · Diagnóstico y Factores ("¿Por qué este resultado?")
Future<void> _abrirFactores(WidgetTester tester) async {
  await iniciarSesionDemo(tester);
  await abrirCursoConEstimacion(tester);
  await tocar(tester, find.text('¿Por qué este resultado?'));
  await esperar(tester, find.text('Diagnóstico y Factores'));
  await esperar(tester, find.text('Lo que más suma al riesgo'));
  await pausa(tester, 800);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 4 · Diagnóstico y Factores', () {
    testWidgets('4.1 La barra superior muestra "Diagnóstico y Factores"',
        (tester) async {
      await _abrirFactores(tester);

      expect(find.text('Diagnóstico y Factores'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.2 El título pregunta "¿Por qué X %?" con el riesgo del curso',
        (tester) async {
      await _abrirFactores(tester);

      expect(find.textContaining('¿Por qué'), findsWidgets);
      expect(find.textContaining('%?'), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.3 Muestra la sección "Lo que más suma al riesgo"',
        (tester) async {
      await _abrirFactores(tester);

      expect(find.text('Lo que más suma al riesgo'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.4 Muestra la sección "Lo que juega a tu favor"',
        (tester) async {
      await _abrirFactores(tester);

      await verAbajoHasta(tester, find.text('Lo que juega a tu favor'));
      expect(find.text('Lo que juega a tu favor'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.5 Ofrece cuestionar los datos de la IA', (tester) async {
      await _abrirFactores(tester);

      final boton = find.textContaining('Cuestionar datos');
      await verAbajoHasta(tester, boton);
      expect(boton, findsOneWidget);

      await tocar(tester, boton);
      await pausa(tester, pausaMedia);

      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('4.6 "Consultar plan de mejora con Tutor IA" abre el tutor',
        (tester) async {
      await _abrirFactores(tester);

      final boton = find.text('Consultar plan de mejora con Tutor IA');
      await verAbajoHasta(tester, boton);
      expect(boton, findsOneWidget);

      await tocar(tester, boton);
      await esperar(tester, find.text('Tutor Inteligente IA'));
      expect(find.text('Tutor Inteligente IA'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.7 "Abrir curso en Moodle" muestra un aviso', (tester) async {
      await _abrirFactores(tester);

      final boton = find.text('Abrir curso en Moodle');
      await verAbajoHasta(tester, boton);
      await tocar(tester, boton);
      await pausa(tester, pausaMedia);

      expect(find.text('Abriendo el curso en Moodle...'), findsOneWidget);
    });

    testWidgets('4.8 El botón de tema cambia entre claro y oscuro',
        (tester) async {
      await _abrirFactores(tester);

      expect(find.byTooltip('Modo oscuro'), findsWidgets);
      await alternarTema(tester);
      expect(find.byTooltip('Modo claro'), findsWidgets);
      await pausa(tester, pausaMedia);

      // Se devuelve al modo claro para no afectar a las demás pruebas.
      await alternarTema(tester);
      expect(find.byTooltip('Modo oscuro'), findsWidgets);
    });

    testWidgets('4.9 Tiene el botón "Actualizar factores"', (tester) async {
      await _abrirFactores(tester);

      expect(find.byTooltip('Actualizar factores'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('4.10 La flecha de regreso vuelve al Diagnóstico de Riesgo',
        (tester) async {
      await _abrirFactores(tester);

      await tester.pageBack();
      await esperar(tester, find.text('Diagnóstico de Riesgo'));
      await pausa(tester, 1000); // termina la animación de salida

      expect(find.text('Diagnóstico de Riesgo'), findsOneWidget);
      expect(find.text('Diagnóstico y Factores'), findsNothing);
      await pausa(tester, pausaMedia);
    });
  });
}
