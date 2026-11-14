import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rumbo_app/views/widgets/course_card.dart';

import 'helpers.dart';

/// Ventana 2 · Asignaturas (Mis Cursos)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ventana 2 · Asignaturas', () {
    testWidgets('2.1 Muestra el título y el saludo al estudiante',
        (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(find.textContaining('Hola,'), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.2 Muestra la tarjeta "Resumen Académico"', (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.text('Resumen Académico'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.3 Lista al menos una tarjeta de curso', (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.byType(CourseCard), findsWidgets);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.4 La barra inferior muestra las 4 pestañas', (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.text('Asignaturas'), findsOneWidget);
      expect(find.text('Tutor IA'), findsOneWidget);
      expect(find.text('Métricas'), findsOneWidget);
      expect(find.text('Logros'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.5 El botón de orden alterna entre prioridad y alfabético',
        (tester) async {
      await iniciarSesionDemo(tester);

      expect(find.text('Por prioridad de riesgo'), findsOneWidget);

      await tocar(tester, find.text('Por prioridad de riesgo'));
      expect(find.text('Alfabético'), findsOneWidget);
      expect(find.text('Por prioridad de riesgo'), findsNothing);
      await pausa(tester, pausaMedia);

      await tocar(tester, find.text('Alfabético'));
      expect(find.text('Por prioridad de riesgo'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.6 El avatar abre el perfil del estudiante', (tester) async {
      await iniciarSesionDemo(tester);

      await tocar(tester, find.byType(CircleAvatar));
      await pausa(tester, pausaMedia);

      expect(find.text('Carrera'), findsOneWidget);
      expect(find.text('Ciclo Académico'), findsOneWidget);
      expect(find.text('Servidor LMS'), findsOneWidget);
      expect(find.text('MoodleCloud (Conectado)'), findsOneWidget);
    });

    testWidgets('2.7 Tocar una tarjeta abre el Diagnóstico de Riesgo',
        (tester) async {
      await iniciarSesionDemo(tester);

      await tocar(tester, find.byType(CourseCard));
      await esperar(tester, find.text('Diagnóstico de Riesgo'));

      expect(find.text('Diagnóstico de Riesgo'), findsOneWidget);
      await pausa(tester, pausaMedia);
    });

    testWidgets('2.8 El ícono de menú abre el menú lateral', (tester) async {
      await iniciarSesionDemo(tester);

      await tocar(tester, find.byTooltip('Menú de opciones'));
      await pausa(tester, pausaMedia);

      expect(find.text('Agenda y Entregas'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
    });
  });
}
