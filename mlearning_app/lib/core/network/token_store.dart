/// Almacén en memoria del token JWT actual.
///
/// El `AuthServiceHttp` guarda el token tras el login y el interceptor de
/// Dio lo adjunta automáticamente en cada petición.
class TokenStore {
  TokenStore._();

  static final TokenStore instance = TokenStore._();

  String? _accessToken;

  String? get accessToken => _accessToken;

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  void setToken(String? token) => _accessToken = token;

  void clear() => _accessToken = null;
}
