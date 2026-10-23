import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo_app/data/models/risk_detail_model.dart';
import 'package:rumbo_app/views/screens/metacognitive_screen.dart';

void main() {
  Widget buildChip(MetacognitiveStat stat) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MetricaChip(stat: stat),
        ),
      ),
    );
  }

  group('Pruebas unitarias de MetricaChip con Promedio, Tareas detalladas y Tendencia', () {
    testWidgets('Muestra "Tareas: 0 de 3 (Completadas)" cuando todo está al día', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'procrastinacion',
        titulo: 'Estado de entregas',
        valor: '0 de 3 (Completadas)',
        estado: 'ok',
        descripcion: 'Todas las tareas han sido entregadas en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tareas pendientes: '), findsOneWidget);
      expect(find.text('0 de 3 (Completadas)'), findsOneWidget);
    });

    testWidgets('Muestra "Tareas: 1 de 2 (1 pendiente)" con total y especificación', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'procrastinacion',
        titulo: 'Estado de entregas',
        valor: '1 de 2 (1 pendiente)',
        estado: 'alerta',
        descripcion: 'Tienes 1 tarea pendiente por entregar en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tareas pendientes: '), findsOneWidget);
      expect(find.text('1 de 2 (1 pendiente)'), findsOneWidget);
    });

    testWidgets('Muestra "Tareas: 1 de 2 (1 vencida)" con total y especificación', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'procrastinacion',
        titulo: 'Estado de entregas',
        valor: '1 de 2 (1 vencida)',
        estado: 'critico',
        descripcion: 'Tienes 1 tarea con fecha límite vencida sin entregar en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tareas pendientes: '), findsOneWidget);
      expect(find.text('1 de 2 (1 vencida)'), findsOneWidget);
    });

    testWidgets('Muestra "Tareas: 2 de 3 (1 vencida · 1 pendiente)" cuando tiene combinadas', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'procrastinacion',
        titulo: 'Estado de entregas',
        valor: '2 de 3 (1 vencida · 1 pendiente)',
        estado: 'critico',
        descripcion: 'Tienes tareas vencidas y pendientes en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tareas pendientes: '), findsOneWidget);
      expect(find.text('2 de 3 (1 vencida · 1 pendiente)'), findsOneWidget);
    });

    testWidgets('MetricaChip no desborda en ancho estrecho (297.4px) con texto largo de tareas', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'procrastinacion',
        titulo: 'Estado de entregas',
        valor: '3 de 3 (1 vencida · 2 pendientes)',
        estado: 'critico',
        descripcion: 'Tienes tareas vencidas y pendientes en Moodle.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 297.4,
                child: Wrap(
                  children: const [
                    MetricaChip(stat: stat),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Tareas pendientes: '), findsOneWidget);
      expect(find.text('3 de 3 (1 vencida · 2 pendientes)'), findsOneWidget);
    });

    testWidgets('Muestra "Promedio: Sin calificaciones" cuando no hay notas', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'promedio',
        titulo: 'Promedio acumulado',
        valor: 'Sin notas',
        unidad: '/ 20',
        estado: 'ok',
        descripcion: 'Aún no se registran calificaciones en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Promedio: '), findsOneWidget);
      expect(find.text('Sin calificaciones'), findsOneWidget);
    });

    testWidgets('Muestra "Promedio: 14.5 / 20" cuando hay notas registradas', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'promedio',
        titulo: 'Promedio acumulado',
        valor: '14.5',
        unidad: '/ 20',
        estado: 'ok',
        descripcion: 'Promedio de evaluaciones.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Promedio: '), findsOneWidget);
      expect(find.text('14.5 / 20'), findsOneWidget);
    });

    testWidgets('Muestra "Tendencia: En ascenso (+0.45)" cuando la tendencia es positiva', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'tendencia',
        titulo: 'Tendencia de notas (Slope)',
        valor: '+0.45',
        unidad: 'pts/corte',
        estado: 'ok',
        descripcion: 'Inclinación y evolución de calificaciones.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tendencia: '), findsOneWidget);
      expect(find.text('En ascenso (+0.45)'), findsOneWidget);
    });

    testWidgets('Muestra "Tendencia: En descenso (-0.30)" cuando la tendencia es negativa', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'tendencia',
        titulo: 'Tendencia de notas (Slope)',
        valor: '-0.30',
        unidad: 'pts/corte',
        estado: 'critico',
        descripcion: 'Inclinación y evolución de calificaciones.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tendencia: '), findsOneWidget);
      expect(find.text('En descenso (-0.30)'), findsOneWidget);
    });

    testWidgets('Muestra "Tendencia: Sin historial" cuando no hay calificaciones suficientes', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'tendencia',
        titulo: 'Tendencia de notas (Slope)',
        valor: 'Sin historial',
        unidad: '',
        estado: 'ok',
        descripcion: 'Se calculará con 2 o más calificaciones.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Tendencia: '), findsOneWidget);
      expect(find.text('Sin historial'), findsOneWidget);
    });

    testWidgets('Muestra "Acceso: Hoy" cuando la inactividad es 0', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'inactividad',
        titulo: 'Días sin entrar al sistema',
        valor: '0',
        unidad: 'días',
        estado: 'ok',
        descripcion: 'Accedió hoy al curso en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Acceso: '), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets('Muestra "Asistencia: Sin registro" si no hay asistencia formal creada', (tester) async {
      const stat = MetacognitiveStat(
        clave: 'asistencia_formal',
        titulo: 'Asistencia a sesiones',
        valor: 'Sin registro',
        estado: 'ok',
        descripcion: 'El docente aún no ha registrado asistencia en Moodle.',
      );

      await tester.pumpWidget(buildChip(stat));
      expect(find.text('Asistencia: '), findsOneWidget);
      expect(find.text('Sin registro'), findsOneWidget);
    });
  });
}
