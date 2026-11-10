import 'package:flutter/foundation.dart';

/// Configuración de acceso a la Rumbo API (Backend FastAPI).
class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl = String.fromEnvironment('RUMBO_API_URL', defaultValue: '');

  /// URL base del backend. Detecta automáticamente emulador Android (10.0.2.2) o local (127.0.0.1).
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static const String loginEndpoint = '/api/auth/login';
  static const String coursesEndpoint = '/api/estudiantes';
  static const String predictEndpoint = '/api/predict';
  static const String tutorEndpoint = '/api/tutor/chat';

  static const Duration timeout = Duration(seconds: 45);
}
