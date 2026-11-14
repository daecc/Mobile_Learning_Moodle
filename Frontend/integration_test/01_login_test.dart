import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Ventana 1 · Inicio de sesión
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 1 · Inicio de sesión', () {
    testWidgets('1.1 Muestra el título, los campos y el botón', (tester) async {
      await abrirApp(tester);

      expect(find.text('Rumbo'), findsWidgets);
      expect(campoUsuario, findsOneWidget);
      expect(campoPassword, findsOneWidget);
      expect(botonIngresar, findsOneWidget);
      await pausa(tester);
    });

    testWidgets('1.2 Con los campos vacíos muestra un aviso', (tester) async {
      await abrirApp(tester);

      await tocar(tester, botonIngresar);

      expect(
        find.text('Por favor ingresa tu usuario y contraseña de Moodle.'),
        findsOneWidget,
      );
      await pausa(tester, pausaMedia);
    });

    testWidgets('1.3 Con usuario pero sin contraseña muestra un aviso',
        (tester) async {
      await abrirApp(tester);

      await tester.enterText(campoUsuario, 'alumno.prueba');
      await pausa(tester);
      await tocar(tester, botonIngresar);

      expect(
        find.text('Por favor ingresa tu usuario y contraseña de Moodle.'),
        findsOneWidget,
      );
      await pausa(tester, pausaMedia);
    });

    testWidgets('1.4 El ojo muestra y oculta la contraseña', (tester) async {
      await abrirApp(tester);

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tocar(tester, find.byIcon(Icons.visibility_outlined));
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await pausa(tester);

      await tocar(tester, find.byIcon(Icons.visibility_off_outlined));
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await pausa(tester);
    });

    testWidgets('1.5 Lo que se escribe en el usuario se refleja en el campo',
        (tester) async {
      await abrirApp(tester);

      await tester.enterText(campoUsuario, 'alumno.prueba');
      await pausa(tester, pausaMedia);

      expect(find.text('alumno.prueba'), findsOneWidget);
    });

    testWidgets('1.6 El acceso rápido "Modo Demo" rellena usuario y contraseña',
        (tester) async {
      await abrirApp(tester);

      await tocar(tester, find.widgetWithText(ActionChip, 'Modo Demo'));
      await pausa(tester, pausaMedia);

      expect(find.text('DEMO'), findsOneWidget);
      final password = tester.widget<TextField>(campoPassword);
      expect(password.controller!.text, 'demo123');
    });

    testWidgets('1.7 El acceso rápido "Guillermo" rellena sus credenciales',
        (tester) async {
      await abrirApp(tester);

      await tocar(tester, find.widgetWithText(ActionChip, 'Guillermo (3 cursos)'));
      await pausa(tester, pausaMedia);

      expect(find.text('guillermo1234'), findsOneWidget);
      final password = tester.widget<TextField>(campoPassword);
      expect(password.controller!.text, 'Base22SW42');
    });

    testWidgets('1.8 Iniciar sesión con DEMO abre la lista de cursos',
        (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(botonIngresar, findsNothing);
      await pausa(tester, pausaMedia);
    });
  });
}
