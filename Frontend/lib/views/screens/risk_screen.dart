import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/risk_detail_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
import '../../viewmodels/riesgo_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../data/services/sync_coordinator.dart';
import '../widgets/liquid_glass_nav_bar.dart';
import '../widgets/risk_gauge.dart';
import 'factors_screen.dart';
import 'main_navigation_screen.dart';
import 'tutor_screen.dart';

/// Panel de riesgo de un curso (tacómetro + alerta + siguiente paso).
class RiskScreen extends StatefulWidget {
  final String courseId;

  const RiskScreen({super.key, required this.courseId});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authStudent = context.read<AuthViewModel>().student;
      context.read<RiesgoViewModel>().loadDetail(
        widget.courseId,
        studentId: authStudent?.idEstudiante ?? 'EST-0001',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RiesgoViewModel>();
    final detail = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Diagnóstico de Riesgo',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeVm, _) => IconButton(
              icon: Icon(
                themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
              ),
              tooltip: themeVm.isDarkMode ? 'Modo claro' : 'Modo oscuro',
              onPressed: () => themeVm.toggleTheme(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondaryOf(context)),
            tooltip: 'Recalcular diagnóstico',
            onPressed: () {
              AppSyncCoordinator.syncAll(
                context,
                activeCourseId: widget.courseId,
                refreshMoodle: true,
              );
            },
          ),
        ],
      ),
      body: detail == null
          ? const Center(child: CircularProgressIndicator())
          : _RiskBody(detail: detail),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: 0,
        onTap: (index) => MainNavigationScreen.switchToTab(context, index),
      ),
    );
  }
}

class _RiskBody extends StatelessWidget {
  final RiskDetailResponse detail;

  const _RiskBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    if (detail.esSinEstimacion) {
      return _SinEstimacionView(detail: detail);
    }
    return _EstimacionView(detail: detail);
  }
}

class _EstimacionView extends StatelessWidget {
  final RiskDetailResponse detail;

  const _EstimacionView({required this.detail});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLevel(detail.nivelRiesgo);
    final soft = AppColors.softForLevel(detail.nivelRiesgo);
    final esCritico = detail.nivelRiesgo == 'CRITICO';

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () async {
        await AppSyncCoordinator.syncAll(
          context,
          activeCourseId: detail.idCurso,
          refreshMoodle: true,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.cleanNombreCurso,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.actualizadoLabel ?? 'Actualizado hoy, 07:30 · se recalcula a diario',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMutedOf(context)),
          ),
          const SizedBox(height: 18),
          if (esCritico) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.riskHighSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ALERTA TEMPRANA',
                style: TextStyle(
                  color: AppColors.riskHigh,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail.alertaMensaje,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: RiskGauge(
              porcentaje: detail.porcentajeRiesgo,
              nivelRiesgo: detail.nivelRiesgo,
              etiqueta: AppColors.labelForLevel(detail.nivelRiesgo),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Rango probable: ${detail.rangoMin}\u2013${detail.rangoMax} %',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (detail.pasoSubtitulo != null)
            _NextStepCard(detail: detail, color: color),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    try {
                      final sId = context.read<AuthViewModel>().student?.idEstudiante;
                      context.read<MetacognitiveViewModel>().registrarRevisionDiagnostico(detail.idCurso, studentId: sId);
                    } catch (_) {}
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FactorsScreen(courseId: detail.idCurso),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('¿Por qué este resultado?'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => abrirMoodleModal(context, detail.cleanNombreCurso),
                  child: const Text('Ir a Moodle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TutorScreen(initialCourseId: detail.idCurso),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandSoftOf(context),
                foregroundColor: AppColors.brand,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.smart_toy_outlined, size: 20),
              label: const Text(
                'Consultar con Tutor IA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  static void abrirMoodleModal(BuildContext context, String nombreCurso) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandSoftOf(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.brand, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aula Virtual MoodleCloud',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                        Text(
                          'UNMSM FISI · Plataforma Oficial',
                          style: TextStyle(fontSize: 12, color: AppColors.textMutedOf(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                nombreCurso,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.link_rounded, size: 18, color: AppColors.brand),
                    SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        'https://rumbo-mobile-learning.moodlecloud.com',
                        style: TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingresa con tus credenciales de estudiante para ver las tareas, foros y calificaciones.',
                style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: const Text('Abrir Moodle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final RiskDetailResponse detail;
  final Color color;

  const _NextStepCard({required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    final esCritico = detail.nivelRiesgo == 'CRITICO';
    final titulo = detail.pasoTitulo ??
        (esCritico ? 'Prioridad inmediata' : 'Qué puedes hacer ahora');

    return Container(
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
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMutedOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.softForLevel(detail.nivelRiesgo),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  detail.pasoTipo == 'quiz'
                      ? Icons.quiz_outlined
                      : Icons.assignment_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  detail.pasoSubtitulo ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
              ),
            ],
          ),
          if (detail.siguientePasoDetalle != null) ...[
            const SizedBox(height: 10),
            Text(
              detail.siguientePasoDetalle!,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SinEstimacionView extends StatelessWidget {
  final RiskDetailResponse detail;

  const _SinEstimacionView({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.cleanNombreCurso,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.actualizadoLabel ?? 'Revisado hoy, 07:30',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMutedOf(context)),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Icon(
              Icons.hourglass_empty,
              size: 54,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sin estimación todavía',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              detail.mensajeSinEstimacion ??
                  'Aún no hay suficiente actividad para estimar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryOf(context)),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Datos reunidos',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    Text(
                      detail.progresoSemana ?? 'Semana 1 de 2',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMutedOf(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: detail.progresoTotal == 0
                        ? 0.5
                        : detail.progresoActual / detail.progresoTotal,
                    minHeight: 8,
                    backgroundColor: AppColors.neutralSoft,
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => _EstimacionView.abrirMoodleModal(context, detail.cleanNombreCurso),
            child: const Text('Abrir curso en Moodle'),
          ),
        ],
      ),
    );
  }
}
