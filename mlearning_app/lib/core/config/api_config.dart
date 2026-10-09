/// Configuración global de la API (backend FastAPI).
///
/// `useMock` permite cambiar entre datos simulados (sin servidor) y el
/// backend real. Para la demo con FastAPI se usa `useMock = false`.
class ApiConfig {
  ApiConfig._();

  /// URL base del backend. En Flutter Web corriendo en Chrome hacia un
  /// backend local. Si el backend corre en otro puerto, ajústalo aquí.
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  /// true = usar servicios Mock (sin backend) / false = consumir API real.
  static const bool useMock = false;

  /// Timeout de red para las peticiones.
  static const Duration timeout = Duration(seconds: 15);
}
