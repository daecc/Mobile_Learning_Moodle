import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 7 · Logros (Gamificación)
Future<void> _abrirLogros(WidgetTester tester) async {
  await iniciarSesionDemo(tester);
  await irAPestana(tester, 'Logros');
  await esperar(tester, find.text('Gamificación'));
  await pausa(tester, 800);
}

Finder _chip(String etiqueta) => find.widgetWithText(ChoiceChip, etiqueta);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 7 · Logros', () {
    testWidgets('7.1 Muestra el título y el subtítulo de la pantalla',
        (tester) async {
      await _abrirLogros(tester);

      expect(find.text('Gamificación'), findsOneWidget);
      expect(find.text('Tus metas y reconocimientos académicos'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('7.2 Muestra la racha, las medallas y la zona segura',
        (tester) async {
      await _abrirLogros(tester);

      expect(find.text('Racha Activa'), findsOneWidget);
      expect(find.text('Medallas'), findsOneWidget);
      expect(find.text('Zona Segura'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('7.3 Muestra el Salón de Logros con sus filtros',
        (tester) async {
      await _abrirLogros(tester);

      await verAbajoHasta(tester, find.text('Salón de Logros'));
      expect(find.text('Salón de Logros'), findsOneWidget);
      expect(_chip('Todos'), findsOneWidget);
      expect(_chip('Moodle LMS'), findsOneWidget);
      expect(_chip('Tutor IA'), findsOneWidget);
      expect(_chip('Hábitos'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('7.4 Con el filtro "Todos" aparecen los 6 logros',
        (tester) async {
      await _abrirLogros(tester);

      await verAbajoHasta(tester, find.text('Salón de Logros'));
      await tocar(tester, _chip('Todos'));

      for (final titulo in const [
        'Entrega Impecable',
        'Guardián del Rendimiento',
        'As de los Cuestionarios',
        'Constancia Semanal',
        'Estratega del Aprendizaje',
        'Mente Inquisitiva',
      ]) {
        expect(find.text(titulo, skipOffstage: false), findsOneWidget,
            reason: 'No aparece el logro "$titulo"');
      }
      await pausa(tester, pausaMedia);
    });

    testWidgets('7.5 El filtro "Moodle LMS" deja solo los logros de Moodle',
        (tester) async {
      await _abrirLogros(tester);

      await verAbajoHasta(tester, find.text('Salón de Logros'));
      await tocar(tester, _chip('Moodle LMS'));
      await pausa(tester, pausaMedia);

      expect(find.text('Entrega Impecable', skipOffstage: false), findsOneWidget);
      expect(find.text('As de los Cuestionarios', skipOffstage: false), findsOneWidget);
      expect(find.text('Mente Inquisitiva', skipOffstage: false), findsNothing);
      expect(find.text('Constancia Semanal', skipOffstage: false), findsNothing);
    });

    testWidgets('7.6 El filtro "Hábitos" deja solo los logros de hábitos',
        (tester) async {
      await _abrirLogros(tester);

      await verAbajoHasta(tester, find.text('Salón de Logros'));
      await tocar(tester, _chip('Hábitos'));
      await pausa(tester, pausaMedia);

      expect(find.text('Constancia Semanal', skipOffstage: false), findsOneWidget);
      expect(find.text('Guardián del Rendimiento', skipOffstage: false), findsOneWidget);
      expect(find.text('Entrega Impecable', skipOffstage: false), findsNothing);
      expect(find.text('Mente Inquisitiva', skipOffstage: false), findsNothing);
    });

    testWidgets('7.7 El filtro "Tutor IA" deja solo los logros del tutor',
        (tester) async {
      await _abrirLogros(tester);

      await verAbajoHasta(tester, find.text('Salón de Logros'));
      await tocar(tester, _chip('Tutor IA'));
      await pausa(tester, pausaMedia);

      expect(find.text('Estratega del Aprendizaje', skipOffstage: false), findsOneWidget);
      expect(find.text('Mente Inquisitiva', skipOffstage: false), findsOneWidget);
      expect(find.text('Entrega Impecable', skipOffstage: false), findsNothing);
      expect(find.text('Constancia Semanal', skipOffstage: false), findsNothing);
    });

    testWidgets('7.8 El botón de ayuda abre las reglas y recompensas',
        (tester) async {
      await _abrirLogros(tester);

      await tocar(tester, find.byTooltip('Reglas del juego y recompensas'));
      await pausa(tester, pausaMedia);

      expect(find.text('Reglas y Recompensas'), findsOneWidget);
      expect(find.text('1. ¿Cómo sumar Puntos Rumbo (XP)?'), findsOneWidget);
    });

    testWidgets('7.9 El botón de tema cambia entre claro y oscuro',
        (tester) async {
      await _abrirLogros(tester);

      expect(find.byTooltip('Modo oscuro'), findsWidgets);
      await alternarTema(tester);
      expect(find.byTooltip('Modo claro'), findsWidgets);
      await pausa(tester, pausaMedia);

      // Se devuelve al modo claro para no afectar a las demás pruebas.
      await alternarTema(tester);
      expect(find.byTooltip('Modo oscuro'), findsWidgets);
    });
  });
}
