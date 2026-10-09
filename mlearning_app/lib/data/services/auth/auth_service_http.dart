import 'package:dio/dio.dart';

import 'package:mlearning_early_warning/core/network/token_store.dart';
import 'package:mlearning_early_warning/data/models/auth/user_model.dart';
import 'package:mlearning_early_warning/data/services/auth/auth_service.dart';

/// Implementación HTTP del servicio de autenticación.
///
/// Consume `POST /auth/login` del backend FastAPI y maneja el token JWT
/// en [TokenStore] para que el resto de peticiones queden autenticadas.
class AuthServiceHttp implements AuthService {
  final Dio _dio;

  /// Sesión en memoria (restaurada durante la vida de la app).
  LoginResponse? _cachedSession;

  AuthServiceHttp({required Dio dio}) : _dio = dio;

  @override
  Future<LoginResponse> login(LoginCredentials credentials) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: credentials.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw AuthException(
          'Respuesta vacía del servidor.',
          code: AuthErrorCode.unknown,
        );
      }

      final loginResponse = LoginResponse.fromJson(data);
      _cachedSession = loginResponse;
      TokenStore.instance.setToken(loginResponse.accessToken);
      return loginResponse;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    _cachedSession = null;
    TokenStore.instance.clear();
  }

  @override
  Future<LoginResponse> refreshToken() async {
    // Para la demo, si existe sesión se reutiliza el usuario.
    if (_cachedSession == null) {
      throw AuthException(
        'No hay sesión para refrescar',
        code: AuthErrorCode.sessionExpired,
      );
    }
    return _cachedSession!;
  }

  @override
  Future<User> getCurrentUser() async {
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
    return _cachedSession != null &&
        _cachedSession!.user.tokenValido &&
        TokenStore.instance.hasToken;
  }

  @override
  Future<void> saveSession(LoginResponse response) async {
    _cachedSession = response;
    TokenStore.instance.setToken(response.accessToken);
  }

  @override
  Future<void> clearSession() async {
    _cachedSession = null;
    TokenStore.instance.clear();
  }

  AuthException _mapDioError(DioException e) {
    final status = e.response?.statusCode;

    if (status == 401 || status == 403) {
      final detail = _extractDetail(e) ??
          'Credenciales incorrectas. Verifica tu código universitario y contraseña.';
      return AuthException(detail, code: AuthErrorCode.invalidCredentials);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AuthException(
        'Error de conexión con el servidor. Verifica que el backend esté activo.',
        code: AuthErrorCode.networkError,
      );
    }
    return AuthException(
      'Error inesperado al iniciar sesión. Intenta de nuevo.',
      code: AuthErrorCode.unknown,
    );
  }

  String? _extractDetail(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return null;
  }
}
