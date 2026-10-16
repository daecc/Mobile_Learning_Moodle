import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';
import 'risk_badge.dart';

/// Tarjeta moderna de curso adaptable a modo claro y modo oscuro.
class CourseCard extends StatelessWidget {
  final CourseRiskSummary curso;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.curso, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLevel(curso.nivelRiesgo);
    final sinEstimacion = curso.esSinEstimacion;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: AppColors.cardShadowOf(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador lateral de color según nivel de riesgo
                Container(
                  width: 6,
                  color: color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges de código y créditos
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandSoftOf(context),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                curso.codigoCurso,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brand,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${curso.creditos} créditos',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMutedOf(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Nombre del curso
                        Text(
                          curso.nombreCurso,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryOf(context),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Docente asignado
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: AppColors.textMutedOf(context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                curso.docente,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Sección derecha: Porcentaje y Badge
                Padding(
                  padding: const EdgeInsets.only(right: 14, top: 14, bottom: 14),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (sinEstimacion) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neutralSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                curso.fechaEstimacion ?? 'Sin estimación',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${curso.porcentajeRiesgo}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RiskBadge(nivelRiesgo: curso.nivelRiesgo),
                          ],
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMutedOf(context),
                        size: 20,
                      ),
                    ],
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
