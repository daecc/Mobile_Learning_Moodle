/// Perfil básico del estudiante autenticado.
class Student {
  final String idEstudiante;
  final String nombre;
  final String carrera;
  final String ciclo;
  final String email;

  const Student({
    required this.idEstudiante,
    required this.nombre,
    required this.carrera,
    required this.ciclo,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      idEstudiante: json['id_estudiante'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      carrera: json['carrera'] as String? ?? '',
      ciclo: json['ciclo'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_estudiante': idEstudiante,
        'nombre': nombre,
        'carrera': carrera,
        'ciclo': ciclo,
        'email': email,
      };

  /// Primer nombre para saludos cortos ("Hola, Valeria").
  String get primerNombre {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? nombre : partes.first;
  }

  /// Iniciales para el avatar (ej. "Valeria Quispe" -> "VQ").
  String get iniciales {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}
