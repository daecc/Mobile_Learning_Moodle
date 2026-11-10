class ChatMessage {
  final String id;
  final String texto;
  final bool esUsuario;
  final DateTime fecha;
  final List<String> sugerencias;

  ChatMessage({
    required this.id,
    required this.texto,
    required this.esUsuario,
    required this.fecha,
    this.sugerencias = const [],
  });
}

class TutorChatResponseModel {
  final String respuesta;
  final List<String> sugerencias;
  final String? cursoContexto;
  final String? nivelRiesgo;

  TutorChatResponseModel({
    required this.respuesta,
    this.sugerencias = const [],
    this.cursoContexto,
    this.nivelRiesgo,
  });

  factory TutorChatResponseModel.fromJson(Map<String, dynamic> json) {
    return TutorChatResponseModel(
      respuesta: json['respuesta'] as String? ?? '',
      sugerencias: ((json['sugerencias'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      cursoContexto: json['curso_contexto'] as String?,
      nivelRiesgo: json['nivel_riesgo'] as String?,
    );
  }
}
