import 'package:integration_test/integration_test.dart';

import '01_login_test.dart' as login;
import '02_asignaturas_test.dart' as asignaturas;
import '03_riesgo_test.dart' as riesgo;
import '04_factores_test.dart' as factores;
import '05_tutor_test.dart' as tutor;
import '06_metricas_test.dart' as metricas;
import '07_logros_test.dart' as logros;
import '08_menu_lateral_test.dart' as menu;

/// Ejecuta las 8 ventanas una tras otra (cada ventana tiene 8 a 10 pruebas).
/// Para correr una sola ventana, usa directamente su archivo (por ejemplo
/// integration_test/03_riesgo_test.dart).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  login.main();
  asignaturas.main();
  riesgo.main();
  factores.main();
  tutor.main();
  metricas.main();
  logros.main();
  menu.main();
}
