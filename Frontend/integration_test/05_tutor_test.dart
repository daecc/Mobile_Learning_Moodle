import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 5 · Tutor IA
Future<void> _abrirTutor(WidgetTester tester) async {
  await iniciarSesionDemo(tester);
  await irAPestana(tester, 'Tutor IA');
  await esperar(tester, find.text('Tutor Inteligente IA'));
  await pausa(tester, 800);
}

Finder get _campoMensaje => find.byType(TextField);
const String _sugerenciaInicial = '¿Cómo puedo salir de la zona de riesgo?';
const String _mensajeUsuario = 'Hola tutor prueba automatica';

/// Envía [_mensajeUsuario] y espera a que el tutor termine de responder.
Future<void> _enviarMensaje(WidgetTester tester) async {
  await tester.enterText(_campoMensaje, _mensajeUsuario);
  await pausa(tester, 700);
  await tocar(tester, find.byIcon(Icons.send_rounded));
  await pausa(tester, 400);
  await esperarQueDesaparezca(
    tester,
    find.text('Rumbo Tutor está escribiendo...'),
    segundos: 60,
  );
  await pausa(tester, 800);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 5 · Tutor IA', () {
    testWidgets('5.1 Muestra el título y el subtítulo del asistente',
        (tester) async {
      await _abrirTutor(tester);

      expect(find.text('Tutor Inteligente IA'), findsOneWidget);
      expect(find.text('Asistente Académico FISI'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('5.2 Muestra el mensaje de bienvenida del tutor',
        (tester) async {
      await _abrirTutor(tester);

      expect(
        find.textContaining('Rumbo Tutor', findRichText: true),
        findsWidgets,
      );
      await pausa(tester, pausaMedia);
    });

    testWidgets('5.3 Ofrece las sugerencias iniciales de pregunta',
        (tester) async {
      await _abrirTutor(tester);

      expect(find.text(_sugerenciaInicial), findsOneWidget);
      expect(find.text('Ayúdame a organizar un plan de estudio'), findsOneWidget);
      expect(find.text('¿Qué tareas tengo pendientes en Moodle?'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('5.4 Muestra el filtro "General / Todos" y los cursos',
        (tester) async {
      await _abrirTutor(tester);

      expect(find.text('General / Todos'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('5.5 Elegir un curso cambia las sugerencias', (tester) async {
      await _abrirTutor(tester);

      // El primer chip es "General / Todos"; el segundo es un curso.
      await tocar(tester, find.byType(ChoiceChip).at(1));
      await pausa(tester, pausaMedia);

      expect(find.text('¿Cuál es mi riesgo en este curso?'), findsOneWidget);
      expect(find.text(_sugerenciaInicial), findsNothing);
      expect(find.text('Asistente Académico FISI'), findsNothing);
    });

    testWidgets('5.6 El campo de mensaje muestra su texto de ayuda',
        (tester) async {
      await _abrirTutor(tester);

      expect(
        find.text('Pregunta a tu Tutor IA sobre tus cursos...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('5.7 Enviar un mensaje lo muestra y el tutor responde',
        (tester) async {
      await _abrirTutor(tester);

      await _enviarMensaje(tester);

      expect(
        find.textContaining(_mensajeUsuario, findRichText: true),
        findsWidgets,
      );
      expect(find.text('Rumbo Tutor está escribiendo...'), findsNothing);
      await pausa(tester, 1500);
    });

    testWidgets('5.8 "Reiniciar conversación" borra los mensajes',
        (tester) async {
      await _abrirTutor(tester);
      await _enviarMensaje(tester);

      await tocar(tester, find.byTooltip('Reiniciar conversación'));
      await pausa(tester, pausaMedia);

      expect(
        find.textContaining(_mensajeUsuario, findRichText: true),
        findsNothing,
      );
      expect(find.text(_sugerenciaInicial), findsOneWidget);
    });

    testWidgets('5.9 El botón de tema cambia entre claro y oscuro',
        (tester) async {
      await _abrirTutor(tester);

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
