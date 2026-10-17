import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';

/// Tarjeta moderna de curso adaptable a modo claro y modo oscuro.
class CourseCard extends StatelessWidget {
  final CourseRiskSummary curso;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.curso, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLevel(curso.nivelRiesgo);
    final sinEstimacion = curso.esSinEstimacion;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0).withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: AppColors.cardShadowOf(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Créditos / Código y Estado sutil a la derecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${curso.creditos} créditos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryOf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (sinEstimacion)
                      Text(
                        curso.fechaEstimacion ?? 'Sin estimación',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            curso.nivelRiesgo == 'BAJO'
                                ? 'Al día · '
                                : '${AppColors.labelForLevel(curso.nivelRiesgo)} · ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Text(
                            '${curso.porcentajeRiesgo}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nombre limpio del curso
                Text(
                  curso.cleanNombreCurso,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(context),
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Fila inferior: Docente y chevron
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AppColors.textMutedOf(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        curso.docente,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMutedOf(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
