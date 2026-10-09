import 'package:dio/dio.dart';

import 'package:mlearning_early_warning/core/config/api_config.dart';
import 'package:mlearning_early_warning/core/network/token_store.dart';

/// Construye la instancia de [Dio] con la URL base y un interceptor que
/// adjunta el token JWT (si existe) a cada petición.
Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = TokenStore.instance.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}
