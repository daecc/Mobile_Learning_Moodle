import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 6 · Métricas (Control Metacognitivo)
Future<void> _abrirMetricas(WidgetTester tester) async {
  await iniciarSesionDemo(tester);
  await irAPestana(tester, 'Métricas');
  await esperar(tester, find.text('Control Metacognitivo'));

  // Si las métricas aún no se cargaron, se piden con el botón de la pantalla.
  await esperarAlguno(
    tester,
    [find.text('Cursos al día'), find.text('Cargar métricas')],
    segundos: 40,
  );
  if (find.text('Cargar métricas').evaluate().isNotEmpty) {
    await tocar(tester, find.text('Cargar métricas'));
  }
  await esperar(tester, find.text('Cursos al día'), segundos: 40);
  await pausa(tester, 800);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 6 · Métricas', () {
    testWidgets('6.1 Muestra el título y el subtítulo de la pantalla',
        (tester) async {
      await _abrirMetricas(tester);

      expect(find.text('Control Metacognitivo'), findsOneWidget);
      expect(find.text('Autorregulación del aprendizaje'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.2 Muestra las tres tarjetas de resumen', (tester) async {
      await _abrirMetricas(tester);

      expect(find.text('Cursos al día'), findsWidgets);
      expect(find.text('En riesgo'), findsWidgets);
      expect(find.text('Riesgo máx.'), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.3 Muestra la tarjeta de accesos semanales', (tester) async {
      await _abrirMetricas(tester);

      await verAbajoHasta(tester, find.text('Accesos semanales'));
      expect(find.text('Accesos semanales'), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.4 Muestra la sección "Métricas por curso"', (tester) async {
      await _abrirMetricas(tester);

      await verAbajoHasta(tester, find.text('Métricas por curso'));
      expect(find.text('Métricas por curso'), findsWidgets);
      expect(
        find.text('Indicadores clave de tu interacción, notas y entregas en Moodle.'),
        findsWidgets,
      );
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.5 Muestra la sección de reflexión', (tester) async {
      await _abrirMetricas(tester);

      await verAbajoHasta(tester, find.text('Reflexiona'));
      expect(find.text('Reflexiona'), findsWidgets);
      expect(find.text('¿Qué te gustaría mejorar esta semana?'), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.6 El botón de sincronizar vuelve a cargar las métricas',
        (tester) async {
      await _abrirMetricas(tester);

      await tocar(tester, find.byTooltip('Sincronizar métricas con Moodle'));
      await pausa(tester, 800);
      await esperar(tester, find.text('Cursos al día'), segundos: 40);

      expect(find.text('Cursos al día'), findsWidgets);
      expect(find.text('Control Metacognitivo'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('6.7 El botón de tema cambia entre claro y oscuro',
        (tester) async {
      await _abrirMetricas(tester);

      expect(find.byTooltip('Modo oscuro'), findsWidgets);
      await alternarTema(tester);
      expect(find.byTooltip('Modo claro'), findsWidgets);
      await pausa(tester, pausaMedia);

      // Se devuelve al modo claro para no afectar a las demás pruebas.
      await alternarTema(tester);
      expect(find.byTooltip('Modo oscuro'), findsWidgets);
    });

    testWidgets('6.8 Se puede volver a Asignaturas desde la barra inferior',
        (tester) async {
      await _abrirMetricas(tester);

      await irAPestana(tester, 'Asignaturas');

      expect(find.text('Mis Cursos'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });
  });
}
