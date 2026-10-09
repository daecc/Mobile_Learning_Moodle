/// Modelo de usuario autenticado en la app M-Learning.
/// Representa al estudiante con sus datos institucionales y académicos.
class User {
  /// ID único del estudiante (ej. 'EST-0001')
  final String id;

  /// Número de documento / código universitario
  final String codigoUniversitario;

  /// Nombres completos
  final String nombres;

  /// Apellidos completos
  final String apellidos;

  /// Email institucional
  final String email;

  /// Programa de estudios (ej. 'Ingeniería de Sistemas')
  final String programaEstudios;

  /// Ciclo actual
  final int cicloActual;

  /// Facultad
  final String facultad;

  /// Token de sesión (JWT o similar en producción)
  final String? token;

  /// Fecha de expiración del token
  final DateTime? tokenExpiry;

  User({
    required this.id,
    required this.codigoUniversitario,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.programaEstudios,
    required this.cicloActual,
    required this.facultad,
    this.token,
    this.tokenExpiry,
  });

  /// Nombre completo formateado
  String get nombreCompleto => '$nombres $apellidos';

  /// Iniciales para avatar
  String get iniciales {
    final n = nombres.isNotEmpty ? nombres[0] : '';
    final a = apellidos.isNotEmpty ? apellidos[0] : '';
    return '$n$a'.toUpperCase();
  }

  /// Getter compatibilidad: ciclo actual como string (ej. "Ciclo 7")
  String get userCycle => 'Ciclo $cicloActual';

  /// Factory desde JSON (respuesta API login)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_estudiante'] as String,
      codigoUniversitario: json['codigo_universitario'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      email: json['email'] as String,
      programaEstudios: json['programa_estudios'] as String,
      cicloActual: json['ciclo_actual'] as int,
      facultad: json['facultad'] as String,
      token: json['token'] as String?,
      tokenExpiry: json['token_expiry'] != null
          ? DateTime.parse(json['token_expiry'] as String)
          : null,
    );
  }

  /// A JSON para almacenamiento local / envío
  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': id,
      'codigo_universitario': codigoUniversitario,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'programa_estudios': programaEstudios,
      'ciclo_actual': cicloActual,
      'facultad': facultad,
      'token': token,
      'token_expiry': tokenExpiry?.toIso8601String(),
    };
  }

  /// Copia con campos actualizados
  User copyWith({
    String? id,
    String? codigoUniversitario,
    String? nombres,
    String? apellidos,
    String? email,
    String? programaEstudios,
    int? cicloActual,
    String? facultad,
    String? token,
    DateTime? tokenExpiry,
  }) {
    return User(
      id: id ?? this.id,
      codigoUniversitario: codigoUniversitario ?? this.codigoUniversitario,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      programaEstudios: programaEstudios ?? this.programaEstudios,
      cicloActual: cicloActual ?? this.cicloActual,
      facultad: facultad ?? this.facultad,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  /// Verifica si el token está vigente
  bool get tokenValido {
    if (token == null || tokenExpiry == null) return false;
    return DateTime.now().isBefore(tokenExpiry!);
  }

  @override
  String toString() => 'User(id: $id, nombre: $nombreCompleto, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Credenciales de login
class LoginCredentials {
  final String username; // codigo universitario o email
  final String password;

  LoginCredentials({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Respuesta de login
class LoginResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // segundos

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}