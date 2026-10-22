import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/risk_detail_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/riesgo_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../widgets/factor_charts/day_circles_chart.dart';
import '../widgets/factor_charts/quiz_trend_chart.dart';
import '../widgets/factor_charts/tasks_timeline_chart.dart';
import '../widgets/factor_charts/weekly_logins_chart.dart';
import 'tutor_screen.dart';

/// Pantalla explicativa: "¿Por qué este resultado?" con factores y reflexión.
class FactorsScreen extends StatefulWidget {
  final String courseId;

  const FactorsScreen({super.key, required this.courseId});

  @override
  State<FactorsScreen> createState() => _FactorsScreenState();
}

class _FactorsScreenState extends State<FactorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authStudent = context.read<AuthViewModel>().student;
      context.read<RiesgoViewModel>().loadDetail(
        widget.courseId,
        studentId: authStudent?.idEstudiante ?? 'EST-0001',
        refresh: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RiesgoViewModel>();
    final detail = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(
          'Diagnóstico y Factores',
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
            tooltip: 'Actualizar factores',
            onPressed: () {
              final authStudent = context.read<AuthViewModel>().student;
              context.read<RiesgoViewModel>().loadDetail(
                    widget.courseId,
                    studentId: authStudent?.idEstudiante ?? 'EST-0001',
                    refresh: true,
                  );
            },
          ),
        ],
      ),
      body: detail == null
          ? const Center(child: CircularProgressIndicator())
          : _FactorsBody(detail: detail, courseId: widget.courseId),
    );
  }
}

class _FactorsBody extends StatelessWidget {
  final RiskDetailResponse detail;
  final String courseId;

  const _FactorsBody({required this.detail, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final factores = detail.factores;

    if (detail.esSinEstimacion || factores == null) {
      return _SinFactores(detail: detail);
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () async {
        final authStudent = context.read<AuthViewModel>().student;
        await context.read<RiesgoViewModel>().loadDetail(
              courseId,
              studentId: authStudent?.idEstudiante ?? 'EST-0001',
              refresh: true,
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Por qué ${detail.porcentajeRiesgo} %?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.cleanNombreCurso,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 20),
          _HeroCard(factores: factores),
          const SizedBox(height: 26),
          const _SectionTitle('Lo que más suma al riesgo'),
          const SizedBox(height: 12),
          ...factores.riesgos.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FactorCard(
                factor: f,
                color: AppColors.riskHigh,
                chart: _chartFor(f),
                courseName: detail.cleanNombreCurso,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SectionTitle('Lo que juega a tu favor'),
          const SizedBox(height: 12),
          ...factores.favorables.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FactorCard(
                factor: f,
                color: AppColors.riskLow,
                chart: _chartFor(f),
                courseName: detail.cleanNombreCurso,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ReflectionCard(opciones: factores.reflexionOpciones),
          const SizedBox(height: 20),
          _CuestionarDatos(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TutorScreen(
                    initialCourseId: detail.idCurso,
                    initialCourseName: detail.cleanNombreCurso,
                  ),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandSoftOf(context),
                foregroundColor: AppColors.brand,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.smart_toy_outlined, size: 20),
              label: const Text(
                'Consultar plan de mejora con Tutor IA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo el curso en Moodle...')),
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Abrir curso en Moodle'),
          ),
        ],
      ),
    ),
  );
}

  Widget? _chartFor(RiskFactor factor) {
    if (factor.chartValues.isEmpty || factor.chartType == 'none') {
      return null;
    }
    switch (factor.chartType) {
      case 'day_circles':
        return DayCirclesChart(values: factor.chartValues);
      case 'quiz_trend':
        return QuizTrendChart(values: factor.chartValues);
      case 'tasks_timeline':
        return TasksTimelineChart(values: factor.chartValues);
      case 'weekly_logins':
        return WeeklyLoginsChart(values: factor.chartValues);
      default:
        return null;
    }
  }
}

class _HeroCard extends StatelessWidget {
  final FactoresBundle factores;

  const _HeroCard({required this.factores});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandSoftOf(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basado en tus ${factores.periodo} de actividad en Moodle.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(
                texto: '${factores.sumanRiesgo} suman al riesgo',
                color: AppColors.riskHigh,
                fondo: AppColors.riskHighSoft,
              ),
              const SizedBox(width: 8),
              _Badge(
                texto: '${factores.jueganFavor} juegan a tu favor',
                color: AppColors.riskLow,
                fondo: AppColors.riskLowSoft,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Todo esto depende de hábitos que puedes cambiar: si cambian, '
            'la estimación también.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  final Color color;
  final Color fondo;

  const _Badge({
    required this.texto,
    required this.color,
    required this.fondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String texto;

  const _SectionTitle(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryOf(context),
      ),
    );
  }
}

class _FactorCard extends StatelessWidget {
  final RiskFactor factor;
  final Color color;
  final Widget? chart;
  final String courseName;

  const _FactorCard({
    required this.factor,
    required this.color,
    this.chart,
    this.courseName = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTareas = factor.clave == 'tareas' && factor.tareas.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: hasTareas ? () => _mostrarDetalleTareasModal(context, factor, courseName) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        factor.titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ),
                    if (hasTareas)
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AppColors.textSecondaryOf(context),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    factor.subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                ),
                if (chart != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: chart!,
                  ),
                ],
                if (hasTareas) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.brandSoftOf(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 14,
                            color: AppColors.brand,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ver detalle de cada tarea (${factor.tareas.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.brand,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Bottom Sheet moderno con el desglose de tareas, estados y calificaciones
void _mostrarDetalleTareasModal(BuildContext context, RiskFactor factor, String courseName) {
  final tareas = factor.tareas;
  final entregadas = tareas.where((t) => t.estaEntregada).length;
  final pendientes = tareas.where((t) => t.estaPendiente).length;
  final vencidas = tareas.where((t) => t.estaVencida).length;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final surfaceColor = AppColors.surfaceOf(ctx);
      final textPrimary = AppColors.textPrimaryOf(ctx);
      final textSecondary = AppColors.textSecondaryOf(ctx);
      final borderColor = AppColors.borderOf(ctx);
      final bgColor = AppColors.backgroundOf(ctx);

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrastre superior
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Encabezado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalle de Tareas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            courseName.isNotEmpty ? courseName : 'Curso en Moodle',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Badges de resumen rápido
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _ModalBadge(
                      label: '$entregadas entregada${entregadas != 1 ? 's' : ''}',
                      color: AppColors.riskLow,
                      icon: Icons.check_circle_rounded,
                    ),
                    if (pendientes > 0) ...[
                      const SizedBox(width: 8),
                      _ModalBadge(
                        label: '$pendientes pendiente${pendientes != 1 ? 's' : ''}',
                        color: AppColors.riskMedium,
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                    if (vencidas > 0) ...[
                      const SizedBox(width: 8),
                      _ModalBadge(
                        label: '$vencidas vencida${vencidas != 1 ? 's' : ''}',
                        color: AppColors.riskHigh,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(color: borderColor, height: 1),

              // Lista de tareas
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: tareas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final t = tareas[index];
                    return _TaskItemCard(
                      task: t,
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ModalBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ModalBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItemCard extends StatelessWidget {
  final TaskDetailItem task;
  final Color bgColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _TaskItemCard({
    required this.task,
    required this.bgColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (task.estaEntregada) {
      statusColor = AppColors.riskLow;
      statusLabel = 'Entregada';
      statusIcon = Icons.check_circle_rounded;
    } else if (task.estaVencida) {
      statusColor = AppColors.riskHigh;
      statusLabel = 'Vencida';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = AppColors.riskMedium;
      statusLabel = 'Pendiente';
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.nombre,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.fechaLimite != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined, size: 13, color: textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Límite: ${task.fechaLimite}',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                if (task.fechaEntrega != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file_outlined, size: 13, color: AppColors.riskLow),
                        const SizedBox(width: 6),
                        Text(
                          'Entregado: ${task.fechaEntrega}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.riskLow),
                        ),
                      ],
                    ),
                  ),
                if (task.calificacion != null)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Calificación: ${task.calificacion}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  )
                else if (task.estaEntregada)
                  Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, size: 13, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Calificación: Pendiente de corrección por docente',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  )
                else if (task.estaVencida)
                  Row(
                    children: [
                      Icon(Icons.cancel_outlined, size: 13, color: AppColors.riskHigh),
                      const SizedBox(width: 6),
                      Text(
                        'Sin entrega registrada en Moodle',
                        style: TextStyle(fontSize: 12, color: AppColors.riskHigh),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final List<String> opciones;

  const _ReflectionCard({required this.opciones});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            '¿Qué te está costando más?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu respuesta nos ayuda a acompañarte mejor (solo tú la ves).',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMutedOf(context)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opciones.map((op) {
              return ActionChip(
                label: Text(
                  op,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                backgroundColor: AppColors.backgroundOf(context),
                side: BorderSide(color: AppColors.borderOf(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Reflexión guardada localmente. ¡Gracias por compartir!',
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CuestionarDatos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _mostrarDialogo(context),
        icon: const Icon(Icons.help_outline, size: 18),
        label: const Text('¿Algún dato no cuadra? Cuestionar datos de la IA'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
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
              Text(
                '¿Algún dato no cuadra?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuéntanos qué ves distinto y revisaremos la estimación con el servidor.',
                style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
              ),
              const SizedBox(height: 16),
              const _MotivoOpcion('Ya entregué una tarea que figura pendiente'),
              const _MotivoOpcion('Entré al curso y no se refleja mi actividad'),
              const _MotivoOpcion('Mi nota registrada no es la correcta'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotivoOpcion extends StatelessWidget {
  final String texto;

  const _MotivoOpcion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 13.5, color: AppColors.textPrimaryOf(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SinFactores extends StatelessWidget {
  final RiskDetailResponse detail;

  const _SinFactores({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sin estimación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.cleanNombreCurso,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Icon(
              Icons.insights_outlined,
              size: 54,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sin factores calculados aún',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Necesitamos más actividad tuya en el curso para explicarte la estimación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryOf(context)),
            ),
          ),
        ],
      ),
    );
  }
}
