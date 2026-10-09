import 'package:dio/dio.dart';

import 'package:mlearning_early_warning/data/models/risk_model.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';

/// Implementación HTTP del servicio de predicción de riesgo.
///
/// Consume `GET /riesgo?id_estudiante=&id_curso=` del backend FastAPI.
class RiskApiServiceHttp implements RiskApiService {
  final Dio _dio;

  RiskApiServiceHttp({required Dio dio}) : _dio = dio;

  @override
  Future<PrediccionRiesgo> fetchPrediccionRiesgo({
    required String idEstudiante,
    required String idCurso,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/riesgo',
      queryParameters: {
        'id_estudiante': idEstudiante,
        'id_curso': idCurso,
      },
    );

    return PrediccionRiesgo.fromJson(response.data!);
  }
}
