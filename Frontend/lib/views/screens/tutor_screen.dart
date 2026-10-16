import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/theme_viewmodel.dart';

/// Pantalla del Tutor Inteligente IA (Componente IAG-ML del Modelo M-learning).
/// Actualmente estructurada como plantilla vacía para consolidar en la siguiente fase.
class TutorScreen extends StatelessWidget {
  const TutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(context),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutor Inteligente IA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            Text(
              'Componente IAG-ML · Andamiaje cognitivo adaptativo',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMutedOf(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryOf(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => themeVm.toggleTheme(),
            icon: Icon(
              themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
            ),
            tooltip: themeVm.isDarkMode ? 'Modo claro' : 'Modo oscuro',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contenedor de Icono Principal
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoftOf(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brand.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 48,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 24),

                // Chip de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoftOf(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brand),
                      SizedBox(width: 6),
                      Text(
                        'ASISTENTE IA EN PREPARACIÓN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Título descriptivo
                Text(
                  'Tutoría Adaptativa y Resolución de Dudas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 12),

                // Explicación metodológica
                Text(
                  'Este módulo integrará el chat inteligente dialógico para apoyar al estudiante fuera del horario de clase: diagnóstico de patrones de diseño (Singleton, Observer, Factory), aclaración de tareas y recomendaciones adaptativas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                const SizedBox(height: 28),

                // Tarjeta de Vista Previa de Funcionalidades
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderOf(context)),
                    boxShadow: AppColors.cardShadowOf(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacidades de la IA en desarrollo:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PlannedItem(
                        icon: Icons.code_rounded,
                        text: 'Detección y explicación de errores en patrones de diseño de software.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        text: 'Tutoría conversacional contextualizada con los temas de Moodle.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.school_outlined,
                        text: 'Plan de acción personalizado para reducir el porcentaje de riesgo.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botón volver
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Volver a Mis Cursos',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannedItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlannedItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.brand),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondaryOf(context),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
