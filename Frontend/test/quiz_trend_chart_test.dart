import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo_app/views/widgets/factor_charts/quiz_trend_chart.dart';

void main() {
  group('QuizTrendChart tests', () {
    testWidgets('Renders empty widget when values is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTrendChart(values: []),
          ),
        ),
      );
      expect(find.byType(QuizTrendChart), findsOneWidget);
      expect(find.text('Prom.'), findsNothing);
    });

    testWidgets('Renders single value as E1 without separator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTrendChart(values: [15.0]),
          ),
        ),
      );
      expect(find.text('15.0'), findsOneWidget);
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('Prom.'), findsNothing);
    });

    testWidgets('Renders evaluations with decimals and marks last bar as Prom.', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTrendChart(values: [20.0, 16.0, 17.0, 17.7]),
          ),
        ),
      );

      // Verificamos que todos los valores muestran decimales
      expect(find.text('20.0'), findsOneWidget);
      expect(find.text('16.0'), findsOneWidget);
      expect(find.text('17.0'), findsOneWidget);
      expect(find.text('17.7'), findsOneWidget);

      // Verificamos las etiquetas de evaluaciones
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('E3'), findsOneWidget);

      // Verificamos la etiqueta destacada de Promedio
      expect(find.text('Prom.'), findsOneWidget);
    });

    testWidgets('Renders integer and float evaluations correctly with decimal place', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTrendChart(values: [12, 1, 6.5]),
          ),
        ),
      );

      expect(find.text('12.0'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('6.5'), findsOneWidget);
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('Prom.'), findsOneWidget);
    });

    testWidgets('Renders up to multiple evaluations scaling dynamically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTrendChart(values: [14.0, 15.5, 18.0, 16.0, 15.9]),
          ),
        ),
      );

      expect(find.text('14.0'), findsOneWidget);
      expect(find.text('15.5'), findsOneWidget);
      expect(find.text('18.0'), findsOneWidget);
      expect(find.text('16.0'), findsOneWidget);
      expect(find.text('15.9'), findsOneWidget);
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('E3'), findsOneWidget);
      expect(find.text('E4'), findsOneWidget);
      expect(find.text('Prom.'), findsOneWidget);
    });
  });
}
