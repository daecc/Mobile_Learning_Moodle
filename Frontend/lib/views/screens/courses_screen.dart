import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/course_card.dart';
import 'login_screen.dart';
import 'risk_screen.dart';

/// Pantalla principal: lista de cursos con su estimación de riesgo académico.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authStudent = context.read<AuthViewModel>().student;
      context.read<CoursesViewModel>().loadCourses(studentId: authStudent?.idEstudiante);
    });
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.riskHigh, size: 24),
            SizedBox(width: 10),
            Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas salir de tu cuenta de Moodle? Tendrás que volver a autenticarte.',
          style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textMutedOf(context))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.riskHigh,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(120, 42),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthViewModel>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _mostrarPerfil(BuildContext context, CoursesViewModel vm) {
    final authStudent = context.read<AuthViewModel>().student;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior del modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),

              // Avatar grande del estudiante
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.brand,
                child: Text(
                  vm.iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                authStudent?.nombre ?? vm.studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authStudent?.email ?? '${vm.studentId.toLowerCase()}@unmsm.edu.pe',
                style: TextStyle(fontSize: 13, color: AppColors.textMutedOf(context)),
              ),
              const SizedBox(height: 16),

              // Tarjeta informativa institucional
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundOf(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.school_outlined,
                      label: 'Carrera',
                      value: authStudent?.carrera ?? 'Ingeniería de Software (UNMSM)',
                    ),
                    Divider(height: 18, color: AppColors.borderOf(context)),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Ciclo Académico',
                      value: authStudent?.ciclo ?? '9no ciclo · Plan 2018',
                    ),
                    Divider(height: 18, color: AppColors.borderOf(context)),
                    const _InfoRow(
                      icon: Icons.cloud_done_outlined,
                      label: 'Servidor LMS',
                      value: 'MoodleCloud (Conectado)',
                      valueColor: AppColors.riskLow,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Switch interactivo de Modo Oscuro en el modal
              Consumer<ThemeViewModel>(
                builder: (context, themeVm, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeVm.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: themeVm.isDarkMode ? Colors.amber : AppColors.brand,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo Oscuro',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryOf(context),
                              ),
                            ),
                            Text(
                              themeVm.isDarkMode ? 'Tema oscuro activo' : 'Tema claro activo',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: themeVm.isDarkMode,
                        activeThumbColor: AppColors.brand,
                        onChanged: (_) => themeVm.toggleTheme(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de Cerrar Sesión en el perfil
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.riskHigh,
                  side: const BorderSide(color: AppColors.riskHigh),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _confirmarCerrarSesion(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.riskHigh),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.riskHigh),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoursesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      drawer: const AppDrawer(currentRoute: 'courses'),
      body: SafeArea(
        child: switch (vm.status) {
          CoursesStatus.loading => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text(
                    'Consultando MoodleCloud y calculando riesgo...',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryOf(context)),
                  ),
                ],
              ),
            ),
          CoursesStatus.empty => _EmptyState(
              onRetry: () {
                final authStudent = context.read<AuthViewModel>().student;
                vm.loadCourses(studentId: authStudent?.idEstudiante);
              },
              onLogout: () => _confirmarCerrarSesion(context),
            ),
          CoursesStatus.error => _ErrorState(
              onRetry: () {
                final authStudent = context.read<AuthViewModel>().student;
                vm.loadCourses(studentId: authStudent?.idEstudiante);
              },
              onLogout: () => _confirmarCerrarSesion(context),
            ),
          CoursesStatus.loaded => RefreshIndicator(
              color: AppColors.brand,
              onRefresh: () async {
                final authStudent = context.read<AuthViewModel>().student;
                await vm.loadCourses(studentId: authStudent?.idEstudiante);
              },
              child: _LoadedState(
                vm: vm,
                onLogout: () => _confirmarCerrarSesion(context),
                onShowProfile: () => _mostrarPerfil(context, vm),
              ),
            ),
        },
      ),
    );
  }
}

class _LoadedState extends StatelessWidget {
  final CoursesViewModel vm;
  final VoidCallback onLogout;
  final VoidCallback onShowProfile;

  const _LoadedState({
    required this.vm,
    required this.onLogout,
    required this.onShowProfile,
  });

  @override
  Widget build(BuildContext context) {
    final resumen = vm.summary;
    final themeVm = context.watch<ThemeViewModel>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Superior con perfil, tema y acción de cerrar sesión
          Row(
            children: [
              Builder(
                builder: (drawerCtx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  color: AppColors.textPrimaryOf(context),
                  tooltip: 'Menú de opciones',
                  onPressed: () => Scaffold.of(drawerCtx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${vm.primerNombre} 👋',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mis Cursos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryOf(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de alternar Tema (Modo Claro / Modo Oscuro)
              IconButton(
                onPressed: () => themeVm.toggleTheme(),
                icon: Icon(
                  themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
                ),
                tooltip: themeVm.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
              ),

              const SizedBox(width: 4),

              // Avatar interactivo
              InkWell(
                onTap: onShowProfile,
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.brand,
                  child: Text(
                    vm.iniciales,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Botón de Cerrar Sesión en Header
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.riskHigh, size: 22),
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tarjeta Hero con métricas de distribución y explicabilidad
          _HeroCard(resumen: resumen, totalCursos: vm.courses.length),

          const SizedBox(height: 18),

          // Barra de ordenamiento y última sincronización
          Row(
            children: [
              InkWell(
                onTap: vm.toggleSort,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.brand),
                      const SizedBox(width: 6),
                      Text(
                        vm.sortByPriority ? 'Por prioridad de riesgo' : 'Alfabético',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                vm.lastSyncFormatted,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMutedOf(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Lista de tarjetas de cursos
          ...vm.courses.map(
            (curso) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(
                curso: curso,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RiskScreen(courseId: curso.idCurso),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final RiskDistributionSummary resumen;
  final int totalCursos;

  const _HeroCard({required this.resumen, required this.totalCursos});

  String get _mensaje {
    final c = resumen.critico;
    final m = resumen.moderado;
    if (c > 0 && m > 0) {
      return '$c curso${c == 1 ? '' : 's'} requiere${c == 1 ? '' : 'n'} atención prioritaria y $m en observación.';
    }
    if (c > 0) {
      return '$c curso${c == 1 ? '' : 's'} requiere${c == 1 ? '' : 'n'} atención prioritaria esta semana.';
    }
    if (m > 0) {
      return '$m curso${m == 1 ? '' : 's'} en riesgo moderado. Conviene revisar las tareas.';
    }
    return '¡Excelente! Todos tus cursos se encuentran en zona segura.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandSoftOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.brand,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Diagnóstico Predictivo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundOf(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalCursos cursos',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _mensaje,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Chips de resumen por niveles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                icono: Icons.warning_rounded,
                texto: '${resumen.critico} crítico',
                color: AppColors.riskHigh,
                fondo: AppColors.riskHighSoft,
              ),
              _StatusPill(
                icono: Icons.trending_down_rounded,
                texto: '${resumen.moderado} moderado',
                color: AppColors.riskMedium,
                fondo: AppColors.riskMediumSoft,
              ),
              _StatusPill(
                icono: Icons.check_circle_outline_rounded,
                texto: '${resumen.bajo} seguro',
                color: AppColors.riskLow,
                fondo: AppColors.riskLowSoft,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Estimaciones calculadas con IA y actividad real de Moodle (Nielsen H6).',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMutedOf(context)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final Color fondo;

  const _StatusPill({
    required this.icono,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMutedOf(context)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryOf(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _EmptyState({required this.onRetry, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: AppColors.neutral),
            const SizedBox(height: 16),
            Text(
              'No se encontraron cursos activos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprueba que el estudiante tenga cursos matriculados en MoodleCloud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Actualizar cursos'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onLogout,
              child: const Text('Cerrar sesión e intentar con otro usuario'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _ErrorState({required this.onRetry, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.riskHigh),
            const SizedBox(height: 16),
            Text(
              'Error de conexión con el backend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica que FastAPI esté corriendo en tu terminal (python run.py).',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar conexión'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onLogout,
              child: const Text('Volver al login'),
            ),
          ],
        ),
      ),
    );
  }
}
