import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';
import '../../data/models/risk_detail_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'risk_screen.dart';
import 'tutor_screen.dart';

/// Pantalla de Control Metacognitivo (Estrategia 4 del Modelo M-learning).
///
/// Consolida, con datos reales de Moodle, el avance en tareas, el estado de
/// riesgo, la constancia de accesos y las métricas de cada curso para que el
/// estudiante pueda autorregular su estudio.
class MetacognitiveScreen extends StatefulWidget {
  final bool isTab;

  const MetacognitiveScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<MetacognitiveScreen> createState() => _MetacognitiveScreenState();
}

class _MetacognitiveScreenState extends State<MetacognitiveScreen> {
  String? _reflexion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cargar();
    });
  }

  Future<void> _cargar() {
    final courses = context.read<CoursesViewModel>();
    final authStudent = context.read<AuthViewModel>().student;
    final studentId = authStudent?.idEstudiante ?? courses.studentId;
    return context
        .read<MetacognitiveViewModel>()
        .load(courses.courses, studentId);
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final vm = context.watch<MetacognitiveViewModel>();
    final coursesVm = context.watch<CoursesViewModel>();

    // Si los cursos ya están disponibles y las métricas están en espera, cargarlas automáticamente
    if (coursesVm.courses.isNotEmpty &&
        vm.status == MetacognitiveStatus.idle &&
        !vm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cargar();
      });
    }

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
              'Autorregulación del aprendizaje',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMutedOf(context),
                fontWeight: FontWeight.w500,
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
        child: _buildBody(context, vm, coursesVm),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MetacognitiveViewModel vm,
    CoursesViewModel coursesVm,
  ) {
    if (coursesVm.isLoading || vm.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Cargando métricas de autorregulación...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      );
    }
    if (coursesVm.courses.isEmpty) {
      return _Mensaje(
        icono: Icons.menu_book_outlined,
        texto: 'Aún no tienes cursos para analizar.',
      );
    }
    if (vm.status == MetacognitiveStatus.error) {
      return _Mensaje(
        icono: Icons.cloud_off_rounded,
        texto: 'No pudimos cargar tus métricas.',
        accion: FilledButton(
          onPressed: _cargar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
          child: const Text('Reintentar'),
        ),
      );
    }
    if (vm.cursos.isEmpty) {
      return _Mensaje(
        icono: Icons.analytics_outlined,
        texto: 'Presiona para sincronizar métricas con Moodle.',
        accion: FilledButton(
          onPressed: _cargar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
          child: const Text('Cargar métricas'),
        ),
      );
    }

    final estimados =
        coursesVm.courses.where((c) => !c.esSinEstimacion).toList();
    CourseRiskSummary? cursoMax;
    for (final c in estimados) {
      if (cursoMax == null || c.porcentajeRiesgo > cursoMax.porcentajeRiesgo) {
        cursoMax = c;
      }
    }
    final resumen = coursesVm.summary;

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 16, 20, widget.isTab ? 95 : 32),
        children: [
          _HeroAvance(
            entregadas: vm.tareasEntregadas,
            totales: vm.tareasTotales,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  valor: '${resumen.bajo}',
                  etiqueta: 'Cursos al día',
                  color: AppColors.riskLow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  valor: '${resumen.moderado + resumen.critico}',
                  etiqueta: 'En riesgo',
                  color: resumen.critico > 0
                      ? AppColors.riskHigh
                      : (resumen.moderado > 0
                          ? AppColors.riskMedium
                          : AppColors.riskLow),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  valor: cursoMax == null ? '—' : '${cursoMax.porcentajeRiesgo}%',
                  etiqueta: 'Riesgo máx.',
                  color: cursoMax == null
                      ? AppColors.neutral
                      : AppColors.forLevel(cursoMax.nivelRiesgo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AccesosCard(valores: vm.accesosSemanales),
          const SizedBox(height: 22),
          Text(
            'Métricas por curso',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          ...vm.cursos.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CursoMetricasCard(
                datos: c,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RiskScreen(courseId: c.curso.idCurso),
                  ),
                ),
              ),
            ),
          ),
          if (vm.reflexionOpciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ReflexionCard(
              opciones: vm.reflexionOpciones,
              seleccion: _reflexion,
              onSeleccion: (op) => setState(() => _reflexion = op),
              onAbrirTutor: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TutorScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Componentes
// -----------------------------------------------------------------------------

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderOf(context)),
      boxShadow: AppColors.cardShadowOf(context),
    );

class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Widget? accion;

  const _Mensaje({required this.icono, required this.texto, this.accion});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 44, color: AppColors.textMutedOf(context)),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            if (accion != null) ...[const SizedBox(height: 16), accion!],
          ],
        ),
      ),
    );
  }
}

class _HeroAvance extends StatelessWidget {
  final int entregadas;
  final int totales;

  const _HeroAvance({required this.entregadas, required this.totales});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF14244D) : AppColors.brand;
    final ratio = totales == 0 ? 0.0 : (entregadas / totales).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : AppColors.brand.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tu avance en tareas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Datos de Moodle',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (totales == 0)
            Text(
              'Aún no hay tareas registradas en tus cursos.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$entregadas de $totales',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'tareas entregadas en tus cursos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final Color color;

  const _StatCard({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryOf(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesosCard extends StatelessWidget {
  final List<num> valores;

  const _AccesosCard({required this.valores});

  @override
  Widget build(BuildContext context) {
    final maxV = valores.isEmpty
        ? 1.0
        : valores.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos semanales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 14),
          if (valores.isEmpty)
            Text(
              'Todavía no hay accesos semanales registrados para tus cursos.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryOf(context),
              ),
            )
          else ...[
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(valores.length, (i) {
                  final esActual = i == valores.length - 1;
                  final ratio = maxV == 0 ? 0.0 : valores[i] / maxV;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${valores[i]}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: esActual ? FontWeight.w800 : FontWeight.w600,
                              color: esActual
                                  ? AppColors.textPrimaryOf(context)
                                  : AppColors.textMutedOf(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 64 * ratio + 4,
                            decoration: BoxDecoration(
                              color: esActual
                                  ? AppColors.brand
                                  : AppColors.brand.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            esActual ? 'Actual' : 'S${i + 1}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMutedOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu constancia en el aula virtual (todos tus cursos).',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CursoMetricasCard extends StatelessWidget {
  final CourseMetacognitive datos;
  final VoidCallback onTap;

  const _CursoMetricasCard({required this.datos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final curso = datos.curso;
    final color = AppColors.forLevel(curso.nivelRiesgo);

    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        curso.cleanNombreCurso,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryOf(context),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (curso.esSinEstimacion)
                      Text(
                        'Sin estimación',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMutedOf(context),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${curso.nivelRiesgo == 'BAJO' ? 'Al día' : AppColors.labelForLevel(curso.nivelRiesgo)} · ${curso.porcentajeRiesgo}%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (datos.metricas.isEmpty)
                  Text(
                    'Sin métricas registradas todavía.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMutedOf(context),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        datos.metricas.map((m) => _MetricaChip(stat: m)).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricaChip extends StatelessWidget {
  final MetacognitiveStat stat;

  const _MetricaChip({required this.stat});

  String get _texto {
    switch (stat.clave) {
      case 'inactividad':
        return stat.valor == '0'
            ? 'Entraste hoy'
            : '${stat.valor} ${stat.valor == '1' ? 'día' : 'días'} sin entrar';
      case 'promedio':
        return 'Promedio ${stat.valor}${stat.unidad != null ? ' ${stat.unidad}' : ''}';
      case 'entregas':
        return '${stat.valor} tareas pendientes';
      default:
        return '${stat.titulo}: ${stat.valor}';
    }
  }

  Color get _color {
    switch (stat.estado) {
      case 'critico':
        return AppColors.riskHigh;
      case 'alerta':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflexionCard extends StatelessWidget {
  final List<String> opciones;
  final String? seleccion;
  final ValueChanged<String> onSeleccion;
  final VoidCallback onAbrirTutor;

  const _ReflexionCard({
    required this.opciones,
    required this.seleccion,
    required this.onSeleccion,
    required this.onAbrirTutor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflexiona',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Qué te gustaría mejorar esta semana?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opciones.map((op) {
              final activa = op == seleccion;
              return InkWell(
                onTap: () => onSeleccion(op),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: activa ? AppColors.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activa ? AppColors.brand : AppColors.borderOf(context),
                      width: 1.4,
                    ),
                  ),
                  child: Text(
                    op,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: activa
                          ? Colors.white
                          : AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (seleccion != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Puedes conversarlo con tu Tutor Inteligente.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onAbrirTutor,
                  child: const Text(
                    'Abrir Tutor',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
