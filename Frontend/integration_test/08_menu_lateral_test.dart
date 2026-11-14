import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 8 · Menú lateral (se abre con el ícono de las tres rayas)
Future<void> _abrirMenu(WidgetTester tester) async {
  await iniciarSesionDemo(tester);
  await tocar(tester, find.byTooltip('Menú de opciones'));
  await esperar(tester, find.text('Agenda y Entregas'));
  await pausa(tester, 800);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 8 · Menú lateral', () {
    testWidgets('8.1 Muestra el pie con la versión de la app', (tester) async {
      await _abrirMenu(tester);

      expect(find.text('UNMSM · FISI'), findsOneWidget);
      expect(find.text('Rumbo v1.0 · UNMSM'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('8.2 Muestra todas las opciones del menú', (tester) async {
      await _abrirMenu(tester);

      expect(find.text('Agenda y Entregas'), findsOneWidget);
      expect(find.text('Metodología y Cálculos'), findsOneWidget);
      expect(find.text('Ajustes y Notificaciones'), findsOneWidget);
      expect(find.text('Modo Oscuro'), findsOneWidget);
      expect(find.text('Términos y Privacidad'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('8.3 "Agenda y Entregas" muestra el estado de sincronización',
        (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Agenda y Entregas'));
      await pausa(tester, pausaMedia);

      expect(find.textContaining('Sincronizado:'), findsOneWidget);
    });

    testWidgets('8.4 "Metodología y Cálculos" abre su ventana', (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Metodología y Cálculos'));
      await pausa(tester, 1200);

      expect(find.text('Metodología y Cálculos'), findsOneWidget);
      expect(
        find.text('Modelo Predictivo y Gamificación Académica'),
        findsOneWidget,
      );
    });

    testWidgets('8.5 "Ajustes y Notificaciones" abre su ventana', (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Ajustes y Notificaciones'));
      await pausa(tester, 1200);

      expect(find.text('Ajustes y Notificaciones'), findsOneWidget);
      expect(
        find.text('Preferencias de alertas y sincronización'),
        findsOneWidget,
      );
    });

    testWidgets('8.6 "Términos y Privacidad" abre su ventana', (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Términos y Privacidad'));
      await pausa(tester, 1200);

      expect(find.text('Términos y Privacidad'), findsOneWidget);
      expect(find.text('Proyecto Rumbo · UNMSM FISI'), findsOneWidget);
    });

    testWidgets('8.7 El interruptor de Modo Oscuro activa y desactiva el tema',
        (tester) async {
      await _abrirMenu(tester);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tocar(tester, find.byType(Switch));
      await pausa(tester, pausaMedia);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      // Se devuelve al modo claro para no afectar a las demás pruebas.
      await tocar(tester, find.byType(Switch));
      await pausa(tester, pausaMedia);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('8.8 "Cerrar Sesión" pide confirmación y se puede cancelar',
        (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Cerrar Sesión'));
      await pausa(tester, pausaMedia);

      expect(
        find.text('¿Deseas salir de tu cuenta de Moodle? Tendrás que volver a autenticarte.'),
        findsOneWidget,
      );

      await tocar(tester, find.text('Cancelar'));
      await pausa(tester, pausaMedia);

      expect(
        find.text('¿Deseas salir de tu cuenta de Moodle? Tendrás que volver a autenticarte.'),
        findsNothing,
      );
    });

    testWidgets('8.9 Confirmar "Salir" regresa a la pantalla de login',
        (tester) async {
      await _abrirMenu(tester);

      await tocar(tester, find.text('Cerrar Sesión'));
      await pausa(tester, pausaMedia);
      await tocar(tester, find.text('Salir'));

      await esperar(tester, campoUsuario);
      expect(campoUsuario, findsOneWidget);
      expect(botonIngresar, findsOneWidget);
      await pausa(tester, pausaMedia);
    });
  });
}
