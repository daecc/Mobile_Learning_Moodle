import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/theme_viewmodel.dart';

/// Pantalla de Gamificación y Logros (Estrategia 5 del Modelo M-learning).
/// Actualmente estructurada como plantilla vacía para consolidar en la siguiente fase.
class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

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
              'Gamificación y Logros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            Text(
              'Estrategia 5 · Motivación y retención académica',
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
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 24),

                // Chip de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.military_tech_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 6),
                      Text(
                        'LOGROS EN PREPARACIÓN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Título descriptivo
                Text(
                  'Insignias y Progreso Estudiantil',
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
                  'Este módulo incentivará la constancia y el compromiso del estudiante a través de dinámicas de gamificación: rachas de estudio, desbloqueo de insignias por entregas a tiempo y reconocimientos al superar situaciones de riesgo.',
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
                        'Reconocimientos proyectados:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PlannedItem(
                        icon: Icons.workspace_premium_rounded,
                        text: 'Insignia "Entrega Impecable" por enviar tareas sin prórroga.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.local_fire_department_rounded,
                        text: 'Racha de estudio semanal continuo en la plataforma Moodle.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.trending_up_rounded,
                        text: 'Medalla "Superación de Riesgo" al pasar de nivel crítico a seguro.',
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
        Icon(icon, size: 16, color: Colors.amber.shade700),
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
