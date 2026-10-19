import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/chat_message_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/tutor_viewmodel.dart';

/// Pantalla del Tutor Inteligente IA (Componente IAG-ML del Modelo M-learning).
/// Asistente conversacional con andamiaje cognitivo adaptativo según métricas de Moodle.
class TutorScreen extends StatefulWidget {
  final String? initialCourseId;
  final String? initialCourseName;
  final bool isTab;

  const TutorScreen({
    super.key,
    this.initialCourseId,
    this.initialCourseName,
    this.isTab = false,
  });

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCourseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TutorViewModel>().seleccionarCurso(
              widget.initialCourseId,
              widget.initialCourseName,
            );
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviar(String texto) {
    if (texto.trim().isEmpty) return;
    final authStudent = context.read<AuthViewModel>().student;
    final studentId = authStudent?.idEstudiante ?? 'EST-0001';

    _textController.clear();
    context.read<TutorViewModel>().enviarMensaje(texto, studentId: studentId).then((_) {
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final tutorVm = context.watch<TutorViewModel>();
    final coursesVm = context.watch<CoursesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(context),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandSoftOf(context),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.brand, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tutor Inteligente IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  Text(
                    tutorVm.selectedCourseName ?? 'Asistente Académico FISI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedOf(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryOf(context)),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          IconButton(
            onPressed: () => tutorVm.reiniciarChat(),
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondaryOf(context)),
            tooltip: 'Reiniciar conversación',
          ),
          IconButton(
            onPressed: () => themeVm.toggleTheme(),
            icon: Icon(
              themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
            ),
            tooltip: themeVm.isDarkMode ? 'Modo claro' : 'Modo oscuro',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de Curso (Filtro contextual)
            _CourseSelectorBar(
              cursos: coursesVm.courses,
              selectedCourseId: tutorVm.selectedCourseId,
              onSelect: (cId, cName) => tutorVm.seleccionarCurso(cId, cName),
            ),

            // Lista de Mensajes
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: tutorVm.mensajes.length + (tutorVm.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == tutorVm.mensajes.length && tutorVm.isTyping) {
                    return const _TypingIndicator();
                  }
                  final msg = tutorVm.mensajes[index];
                  return _MessageBubble(
                    mensaje: msg,
                    onSugerenciaTap: (sug) => _enviar(sug),
                  );
                },
              ),
            ),

            // Chips de Sugerencias Rápidas
            if (tutorVm.sugerenciasActivas.isNotEmpty && !tutorVm.isTyping)
              _QuickSuggestions(
                sugerencias: tutorVm.sugerenciasActivas,
                onSelect: (sug) => _enviar(sug),
              ),

            // Barra inferior de entrada
            _InputBar(
              controller: _textController,
              isTyping: tutorVm.isTyping,
              bottomPadding: widget.isTab ? 84.0 : 14.0,
              onSend: () => _enviar(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseSelectorBar extends StatelessWidget {
  final List<dynamic> cursos;
  final String? selectedCourseId;
  final Function(String?, String?) onSelect;

  const _CourseSelectorBar({
    required this.cursos,
    required this.selectedCourseId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(bottom: BorderSide(color: AppColors.borderOf(context))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('General / Todos'),
              selected: selectedCourseId == null,
              onSelected: (_) => onSelect(null, null),
              selectedColor: AppColors.brandSoftOf(context),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: selectedCourseId == null ? FontWeight.w800 : FontWeight.w500,
                color: selectedCourseId == null ? AppColors.brand : AppColors.textSecondaryOf(context),
              ),
            ),
          ),
          ...cursos.map((c) {
            final isSelected = c.idCurso == selectedCourseId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c.codigoCurso),
                selected: isSelected,
                onSelected: (_) => onSelect(c.idCurso, c.cleanNombreCurso),
                selectedColor: AppColors.brandSoftOf(context),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? AppColors.brand : AppColors.textSecondaryOf(context),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage mensaje;
  final Function(String) onSugerenciaTap;

  const _MessageBubble({
    required this.mensaje,
    required this.onSugerenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    final esUser = mensaje.esUsuario;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: esUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.brandSoftOf(context),
              child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.brand),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: esUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: esUser
                        ? AppColors.brand
                        : AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(esUser ? 18 : 4),
                      bottomRight: Radius.circular(esUser ? 4 : 18),
                    ),
                    border: esUser
                        ? null
                        : Border.all(color: AppColors.borderOf(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _RichMarkdownText(
                    texto: mensaje.texto,
                    color: esUser ? Colors.white : AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mensaje.fecha.hour.toString().padLeft(2, '0')}:${mensaje.fecha.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          if (esUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.brand.withValues(alpha: 0.15),
              child: const Icon(Icons.person_rounded, size: 16, color: AppColors.brand),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.brandSoftOf(context),
            child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.brand),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand),
                ),
                const SizedBox(width: 10),
                Text(
                  'Rumbo Tutor está escribiendo...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMutedOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSuggestions extends StatelessWidget {
  final List<String> sugerencias;
  final Function(String) onSelect;

  const _QuickSuggestions({
    required this.sugerencias,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: sugerencias.length,
        itemBuilder: (context, index) {
          final sug = sugerencias[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: AppColors.surfaceOf(context),
              side: BorderSide(color: AppColors.brand.withValues(alpha: 0.3)),
              avatar: const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.brand),
              label: Text(
                sug,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brand,
                ),
              ),
              onPressed: () => onSelect(sug),
            ),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;
  final double bottomPadding;

  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
    this.bottomPadding = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(top: BorderSide(color: AppColors.borderOf(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundOf(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimaryOf(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Pregunta a tu Tutor IA sobre tus cursos...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMutedOf(context),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isTyping ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _RichMarkdownText extends StatelessWidget {
  final String texto;
  final Color color;

  const _RichMarkdownText({
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Parsea **negritas** para convertirlas a TextSpans estilizados sin asteriscos
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(texto)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: texto.substring(lastMatchEnd, match.start),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: color,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < texto.length) {
      spans.add(
        TextSpan(
          text: texto.substring(lastMatchEnd),
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: color,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
