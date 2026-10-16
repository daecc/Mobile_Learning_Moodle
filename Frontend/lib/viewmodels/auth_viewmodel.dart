import 'package:flutter/foundation.dart';

import '../data/models/student_model.dart';
import '../data/services/api_service.dart';

/// Estado de autenticación (MVVM).
class AuthViewModel extends ChangeNotifier {
  final ApiService apiService;

  AuthViewModel({required this.apiService});

  Student? _student;
  bool _isLoading = false;
  String? _error;

  Student? get student => _student;
  bool get isLoggedIn => _student != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName => _student?.nombre ?? 'Estudiante';
  String get iniciales => _student?.iniciales ?? '?';

  Future<bool> login(String codigo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _student = await apiService.login(codigo, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      _error = msg.isNotEmpty ? msg : 'No pudimos iniciar sesión. Revisa tus datos e inténtalo de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _student = null;
    _error = null;
    notifyListeners();
  }
}
