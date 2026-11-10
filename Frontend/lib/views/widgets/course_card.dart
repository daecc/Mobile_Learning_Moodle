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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: AppColors.cardShadowOf(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parte superior e intermedia: Información a la izquierda + Anillo de porcentaje a la derecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(20),
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
                          const SizedBox(height: 12),
                          Text(
                            curso.cleanNombreCurso,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryOf(context),
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    if (sinEstimacion)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          curso.fechaEstimacion ?? 'Sin estimación',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedOf(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${curso.porcentajeRiesgo}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Círculo exterior suave tipo doble anillo
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                // Arco de progreso circular
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: CircularProgressIndicator(
                                    value: (curso.porcentajeRiesgo.clamp(0, 100) / 100.0) == 0
                                        ? 0.08
                                        : (curso.porcentajeRiesgo.clamp(0, 100) / 100.0),
                                    strokeWidth: 3.2,
                                    backgroundColor: color.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

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
                          fontSize: 13,
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
