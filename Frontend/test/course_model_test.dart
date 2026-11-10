import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo_app/data/models/course_model.dart';

void main() {
  group('formatCourseTitle tests', () {
    test('Cleans Curso202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2 correctly', () {
      final formatted = formatCourseTitle('Curso202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2');
      expect(formatted, 'Taller de Construcción de Software Móvil');
    });

    test('Cleans 202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2 without Curso prefix', () {
      final formatted = formatCourseTitle('202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2');
      expect(formatted, 'Taller de Construcción de Software Móvil');
    });

    test('Cleans 202W1001-ANALITICA_DE_DATOS-2018-2_26.2 correctly', () {
      final formatted = formatCourseTitle('202W1001-ANALITICA_DE_DATOS-2018-2_26.2');
      expect(formatted, 'Analítica de Datos');
    });

    test('Cleans GARANTIA DE SOFTWARE - G1 correctly', () {
      final formatted = formatCourseTitle('GARANTIA DE SOFTWARE - G1');
      expect(formatted, 'Garantía de Software - G1');
    });

    test('Cleans GESTION DE MANTENIMIENTO DEL SOFTWARE - G1 correctly', () {
      final formatted = formatCourseTitle('GESTION DE MANTENIMIENTO DEL SOFTWARE - G1');
      expect(formatted, 'Gestión de Mantenimiento del Software - G1');
    });

    test('Preserves already clean titles', () {
      expect(formatCourseTitle('Base de Datos II'), 'Base de Datos II');
      expect(formatCourseTitle('Patrones de Diseño de Software'), 'Patrones de Diseño de Software');
      expect(formatCourseTitle('Ingeniería de Requisitos'), 'Ingeniería de Requisitos');
    });
  });
}
