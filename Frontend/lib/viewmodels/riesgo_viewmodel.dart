import 'package:flutter/foundation.dart';

import '../data/models/risk_detail_model.dart';
import '../data/services/api_service.dart';

enum RiesgoStatus { idle, loading, loaded, error }

/// Estado de las pantallas de riesgo y factores (MVVM).
class RiesgoViewModel extends ChangeNotifier {
  final ApiService apiService;

  RiesgoViewModel({required this.apiService});

  RiskDetailResponse? _detail;
  RiesgoStatus _status = RiesgoStatus.idle;
  String? _error;
  String? _courseId;

  RiskDetailResponse? get detail => _detail;
  RiesgoStatus get status => _status;
  bool get isLoading => _status == RiesgoStatus.loading;
  String? get error => _error;
  String? get courseId => _courseId;

  Future<void> loadDetail(
    String courseId, {
    String studentId = 'EST-0001',
    bool refresh = false,
  }) async {
    // Si se consulta un curso nuevo, limpiar los datos previos para evitar que se muestren desfasados
    if (_courseId != courseId) {
      _detail = null;
    }
    _courseId = courseId;
    _status = RiesgoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _detail = await apiService.getCourseRiskDetail(
        studentId,
        courseId,
        refresh: refresh,
      );
      _status = RiesgoStatus.loaded;
    } catch (e) {
      _error = 'No pudimos calcular el riesgo de este curso.';
      _status = RiesgoStatus.error;
    }
    notifyListeners();
  }
}
