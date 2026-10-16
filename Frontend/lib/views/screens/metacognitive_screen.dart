import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/theme_viewmodel.dart';

/// Pantalla de Control Metacognitivo (Estrategia 4 del Modelo M-learning).
/// Actualmente estructurada como plantilla vacía para consolidar en la siguiente fase.
class MetacognitiveScreen extends StatelessWidget {
  const MetacognitiveScreen({super.key});

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
              'Control Metacognitivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            Text(
              'Estrategia 4 · Autorregulación del aprendizaje',
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
                    Icons.insights_rounded,
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
                      Icon(Icons.construction_rounded, size: 14, color: AppColors.brand),
                      SizedBox(width: 6),
                      Text(
                        'MÓDULO EN CONSTRUCCIÓN',
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
                  'Panel de Monitoreo y Autorregulación',
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
                  'En esta sección se consolidarán las métricas globales del semestre: horas de conexión, ritmo de cumplimiento de entregas, autoevaluaciones periódicas y estadísticas longitudinales de interacción con Moodle.',
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
                        'Funcionalidades planificadas:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PlannedItem(
                        icon: Icons.access_time_rounded,
                        text: 'Historial semanal de horas de dedicación al aula virtual.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.task_alt_rounded,
                        text: 'Tasa de cumplimiento de actividades sincrónicas y asincrónicas.',
                      ),
                      const SizedBox(height: 8),
                      _PlannedItem(
                        icon: Icons.warning_amber_rounded,
                        text: 'Alertas predictivas antes del cierre de actas académicas.',
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
