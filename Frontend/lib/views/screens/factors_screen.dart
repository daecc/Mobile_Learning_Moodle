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
          'Explicabilidad (Nielsen H6)',
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
        ],
      ),
      body: detail == null
          ? const Center(child: CircularProgressIndicator())
          : _FactorsBody(detail: detail),
    );
  }
}

class _FactorsBody extends StatelessWidget {
  final RiskDetailResponse detail;

  const _FactorsBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final factores = detail.factores;

    if (detail.esSinEstimacion || factores == null) {
      return _SinFactores(detail: detail);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Por qué ${detail.porcentajeRiesgo} %?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.nombreCurso,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ReflectionCard(opciones: factores.reflexionOpciones),
          const SizedBox(height: 20),
          _CuestionarDatos(),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo el curso en Moodle...')),
              );
            },
            child: const Text('Abrir curso en Moodle'),
          ),
        ],
      ),
    );
  }

  Widget _chartFor(RiskFactor factor) {
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
        return const SizedBox.shrink();
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
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basado en tus ${factores.periodo} de actividad en Moodle.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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
          const Text(
            'Todo esto depende de hábitos que puedes cambiar: si cambian, '
            'la estimación también.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
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
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FactorCard extends StatelessWidget {
  final RiskFactor factor;
  final Color color;
  final Widget? chart;

  const _FactorCard({required this.factor, required this.color, this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              factor.subtitulo,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué te está costando más?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu respuesta nos ayuda a acompañarte mejor (solo tú la ves).',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opciones.map((op) {
              return ActionChip(
                label: Text(op),
                backgroundColor: AppColors.neutralSoft,
                side: const BorderSide(color: AppColors.border),
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
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Algún dato no cuadra?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Cuéntanos qué ves distinto y revisaremos la estimación.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            _MotivoOpcion('Ya entregué una tarea que figura pendiente'),
            _MotivoOpcion('Entré al curso y no se refleja mi actividad'),
            _MotivoOpcion('Mi nota registrada no es la correcta'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
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
            child: Text(texto, style: const TextStyle(fontSize: 13.5)),
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
          const Text(
            'Sin estimación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.nombreCurso,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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
          const Center(
            child: Text(
              'Sin factores calculados aún',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Necesitamos más actividad tuya en el curso para explicarte la estimación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
