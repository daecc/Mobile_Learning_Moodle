import 'package:flutter/foundation.dart';

import '../data/models/chat_message_model.dart';
import '../data/services/api_service.dart';

class TutorViewModel extends ChangeNotifier {
  final ApiService apiService;

  TutorViewModel({required this.apiService}) {
    _iniciarChat();
  }

  final List<ChatMessage> _mensajes = [];
  bool _isTyping = false;
  String? _selectedCourseId;
  String? _selectedCourseName;
  List<String> _sugerenciasActivas = [
    '¿Cómo puedo salir de la zona de riesgo?',
    'Ayúdame a organizar un plan de estudio',
    '¿Qué tareas tengo pendientes en Moodle?',
  ];

  List<ChatMessage> get mensajes => List.unmodifiable(_mensajes);
  bool get isTyping => _isTyping;
  String? get selectedCourseId => _selectedCourseId;
  String? get selectedCourseName => _selectedCourseName;
  List<String> get sugerenciasActivas => _sugerenciasActivas;

  void seleccionarCurso(String? courseId, [String? courseName]) {
    _selectedCourseId = courseId;
    _selectedCourseName = courseName;
    notifyListeners();

    if (courseName != null) {
      _mensajes.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          texto: 'Has seleccionado el curso **$courseName**. Ahora responderé enfocándome en su estado y métricas.',
          esUsuario: false,
          fecha: DateTime.now(),
          sugerencias: [
            '¿Cuál es mi riesgo en este curso?',
            '¿Qué entregas tengo pendientes?',
            'Dame un plan de estudio para este curso',
          ],
        ),
      );
      _sugerenciasActivas = [
        '¿Cuál es mi riesgo en este curso?',
        '¿Qué entregas tengo pendientes?',
        'Dame un plan de estudio para este curso',
      ];
      notifyListeners();
    }
  }

  void _iniciarChat() {
    _mensajes.add(
      ChatMessage(
        id: 'welcome_1',
        texto: '¡Hola! Soy **Rumbo Tutor**, tu asistente inteligente de andamiaje cognitivo.\n\nPuedo ayudarte a resolver dudas sobre tus asignaturas, darte recomendaciones personalizadas de estudio y analizar cómo mejorar tu rendimiento en Moodle.',
        esUsuario: false,
        fecha: DateTime.now(),
        sugerencias: _sugerenciasActivas,
      ),
    );
  }

  Future<void> enviarMensaje(String texto, {required String studentId}) async {
    final cleanText = texto.trim();
    if (cleanText.isEmpty || _isTyping) return;

    // 1. Agregar mensaje del usuario
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      texto: cleanText,
      esUsuario: true,
      fecha: DateTime.now(),
    );
    _mensajes.add(userMsg);
    _isTyping = true;
    _sugerenciasActivas = [];
    notifyListeners();

    // 2. Armar historial para el backend
    final historyList = _mensajes.map((m) {
      return {
        'rol': m.esUsuario ? 'user' : 'assistant',
        'contenido': m.texto,
      };
    }).toList();

    // 3. Consultar servicio
    try {
      final resp = await apiService.sendMessageToTutor(
        studentId: studentId,
        courseId: _selectedCourseId,
        message: cleanText,
        history: historyList,
      );

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        texto: resp.respuesta,
        esUsuario: false,
        fecha: DateTime.now(),
        sugerencias: resp.sugerencias,
      );
      _mensajes.add(botMsg);
      if (resp.sugerencias.isNotEmpty) {
        _sugerenciasActivas = resp.sugerencias;
      }
    } catch (_) {
      _mensajes.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          texto: 'Lo siento, tuve un inconveniente temporal para procesar tu consulta. Por favor, intenta de nuevo.',
          esUsuario: false,
          fecha: DateTime.now(),
          sugerencias: [
            '¿Cómo mejorar mi nota?',
            'Ver estado de riesgo',
          ],
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void reiniciarChat() {
    _mensajes.clear();
    _sugerenciasActivas = [
      '¿Cómo puedo salir de la zona de riesgo?',
      'Ayúdame a organizar un plan de estudio',
      '¿Qué tareas tengo pendientes en Moodle?',
    ];
    _iniciarChat();
    notifyListeners();
  }
}
