import 'package:mlearning_early_warning/data/models/auth/user_model.dart';

/// Interfaz abstracta para el servicio de autenticación.
/// Permite intercambiar Mock por implementación real (HTTP/Dio + JWT).
abstract class AuthService {
  /// Inicia sesión con credenciales institucionales.
  /// Retorna [LoginResponse] con user + tokens.
  /// Lanza [AuthException] si credenciales inválidas o error de red.
  Future<LoginResponse> login(LoginCredentials credentials);

  /// Cierra sesión (invalida token en servidor si aplica).
  Future<void> logout();

  /// Refresca el access token usando refresh token.
  Future<LoginResponse> refreshToken();

  /// Obtiene perfil actual del usuario autenticado.
  Future<User> getCurrentUser();

  /// Verifica si hay sesión válida almacenada localmente.
  Future<bool> hasValidSession();

  /// Guarda tokens de forma segura (SecureStorage en producción).
  Future<void> saveSession(LoginResponse response);

  /// Limpia sesión almacenada.
  Future<void> clearSession();
}

/// Excepción personalizada para errores de autenticación.
class AuthException implements Exception {
  final String message;
  final AuthErrorCode code;

  AuthException(this.message, {this.code = AuthErrorCode.unknown});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Códigos de error de autenticación para manejo específico en UI.
enum AuthErrorCode {
  /// Credenciales incorrectas
  invalidCredentials,

  /// Cuenta bloqueada / deshabilitada
  accountDisabled,

  /// Error de conexión / servidor
  networkError,

  /// Sesión expirada
  sessionExpired,

  /// Error desconocido
  unknown,
}

/// Implementación Mock del servicio de autenticación.
/// Simula login contra backend con delay y usuarios de prueba realistas.
class AuthServiceMock implements AuthService {
  static const Duration _networkDelay = Duration(seconds: 1, milliseconds: 500);

  // Usuarios de prueba basados en el dataset real
  static final Map<String, User> _mockUsers = {
    'EST-0001': User(
      id: 'EST-0001',
      codigoUniversitario: '20210001',
      nombres: 'Juan Carlos',
      apellidos: 'Pérez González',
      email: 'juan.perez@universidad.edu.pe',
      programaEstudios: 'Ingeniería de Sistemas',
      cicloActual: 7,
      facultad: 'Facultad de Ingeniería',
    ),
    'EST-0002': User(
      id: 'EST-0002',
      codigoUniversitario: '20210002',
      nombres: 'María Fernanda',
      apellidos: 'López Ruiz',
      email: 'maria.lopez@universidad.edu.pe',
      programaEstudios: 'Ingeniería de Software',
      cicloActual: 6,
      facultad: 'Facultad de Ingeniería',
    ),
    'EST-0003': User(
      id: 'EST-0003',
      codigoUniversitario: '20210003',
      nombres: 'Carlos Alberto',
      apellidos: 'Martínez Silva',
      email: 'carlos.martinez@universidad.edu.pe',
      programaEstudios: 'Ingeniería de Sistemas',
      cicloActual: 8,
      facultad: 'Facultad de Ingeniería',
    ),
  };

  // Password único para todos los mock: "123456"
  static const String _mockPassword = '123456';

  // Sesión en memoria (simula SecureStorage)
  LoginResponse? _cachedSession;

  @override
  Future<LoginResponse> login(LoginCredentials credentials) async {
    await Future.delayed(_networkDelay);

    // Buscar usuario por código universitario o email
    final user = _mockUsers.values.firstWhere(
      (u) =>
          u.codigoUniversitario == credentials.username ||
          u.email == credentials.username,
      orElse: () => throw AuthException(
            'Credenciales incorrectas. Verifica tu código universitario y contraseña.',
            code: AuthErrorCode.invalidCredentials,
          ),
    );

    // Verificar password (mock)
    if (credentials.password != _mockPassword) {
      throw AuthException(
        'Contraseña incorrecta. Intenta de nuevo.',
        code: AuthErrorCode.invalidCredentials,
      );
    }

    // Generar tokens mock
    final now = DateTime.now();
    final expiresIn = 3600; // 1 hora
    final response = LoginResponse(
      user: user.copyWith(
        token: 'mock_jwt_token_${user.id}_${now.millisecondsSinceEpoch}',
        tokenExpiry: now.add(Duration(seconds: expiresIn)),
      ),
      accessToken: 'mock_access_${user.id}',
      refreshToken: 'mock_refresh_${user.id}',
      expiresIn: expiresIn,
    );

    _cachedSession = response;
    return response;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedSession = null;
  }

  @override
  Future<LoginResponse> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_cachedSession == null) {
      throw AuthException(
        'No hay sesión para refrescar',
        code: AuthErrorCode.sessionExpired,
      );
    }

    final newExpiry = DateTime.now().add(Duration(seconds: _cachedSession!.expiresIn));
    final refreshed = LoginResponse(
      user: _cachedSession!.user.copyWith(
        token: 'mock_jwt_refreshed_${_cachedSession!.user.id}_${DateTime.now().millisecondsSinceEpoch}',
        tokenExpiry: newExpiry,
      ),
      accessToken: 'mock_access_refreshed_${_cachedSession!.user.id}',
      refreshToken: _cachedSession!.refreshToken,
      expiresIn: _cachedSession!.expiresIn,
    );

    _cachedSession = refreshed;
    return refreshed;
  }

  @override
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_cachedSession == null) {
      throw AuthException(
        'No hay usuario autenticado',
        code: AuthErrorCode.sessionExpired,
      );
    }

    return _cachedSession!.user;
  }

  @override
  Future<bool> hasValidSession() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _cachedSession != null && _cachedSession!.user.tokenValido;
  }

  @override
  Future<void> saveSession(LoginResponse response) async {
    _cachedSession = response;
  }

  @override
  Future<void> clearSession() async {
    _cachedSession = null;
  }
}