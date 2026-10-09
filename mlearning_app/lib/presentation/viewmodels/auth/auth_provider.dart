import 'package:flutter/foundation.dart';
import 'package:mlearning_early_warning/data/models/auth/user_model.dart';
import 'package:mlearning_early_warning/data/services/auth/auth_service.dart';

/// Estados posibles del flujo de autenticación.
enum AuthState {
  /// Estado inicial, verificando sesión guardada
  initializing,

  /// No autenticado, listo para login
  unauthenticated,

  /// Autenticando (login en progreso)
  authenticating,

  /// Autenticado correctamente
  authenticated,

  /// Error en autenticación
  error,
}

/// Provider principal para el estado de autenticación.
///
/// Responsabilidades:
/// - Gestionar estado global de auth (user, token, loading, error)
/// - Orquestar login, logout, refresh token
/// - Persistir/restaurar sesión (delegado al AuthService)
/// - Exponer getters listos para UI
/// - **NO navega directamente** (la Vista escucha cambios y navega)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  // Estado interno
  AuthState _state = AuthState.initializing;
  User? _user;
  String? _errorMessage;
  bool _isRestoringSession = false;

  // Getters públicos
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.authenticating || _isRestoringSession;
  bool get isInitializing => _state == AuthState.initializing;
  String get userDisplayName => _user?.nombreCompleto ?? 'Usuario';
  String get userInitials => _user?.iniciales ?? '??';
  String get userProgram => _user?.programaEstudios ?? '';
  String get userCycle => _user != null ? 'Ciclo ${_user!.cicloActual}' : '';

  AuthProvider({required AuthService authService}) : _authService = authService {
    _initialize();
  }

  /// Inicializa el provider: restaura sesión si existe
  Future<void> _initialize() async {
    _isRestoringSession = true;
    _setState(AuthState.initializing);

    try {
      final hasSession = await _authService.hasValidSession();
      if (hasSession) {
        final user = await _authService.getCurrentUser();
        _user = user;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      // Si falla restauración, tratar como no autenticado
      await _authService.clearSession();
      _setState(AuthState.unauthenticated);
    } finally {
      _isRestoringSession = false;
    }
  }

  /// Inicia sesión con credenciales.
  /// Retorna true si éxito, false si error (errorMessage se setea).
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (_state == AuthState.authenticating) return false;

    _setState(AuthState.authenticating);
    _errorMessage = null;

    try {
      final credentials = LoginCredentials(username: username, password: password);
      final response = await _authService.login(credentials);

      await _authService.saveSession(response);
      _user = response.user;
      _setState(AuthState.authenticated);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setState(AuthState.error);
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado. Intenta de nuevo.';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Cierra sesión y limpia estado.
  Future<void> logout() async {
    _setState(AuthState.authenticating); // Loading mientras cierra
    try {
      await _authService.logout();
      await _authService.clearSession();
    } finally {
      _user = null;
      _errorMessage = null;
      _setState(AuthState.unauthenticated);
    }
  }

  /// Refresca token proactivamente (llamar antes de requests sensibles).
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      await _authService.saveSession(response);
      _user = response.user;
      return true;
    } on AuthException catch (e) {
      if (e.code == AuthErrorCode.sessionExpired) {
        await logout();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Limpia mensaje de error (ej. al volver a intentar login).
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Actualiza datos del usuario localmente (ej. tras edición de perfil).
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}