import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';
import '../../main.dart';
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

class _CoursesScreenState extends State<CoursesScreen> with RouteAware {
  Key _lottieKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authStudent = context.read<AuthViewModel>().student;
      context.read<CoursesViewModel>().loadCourses(studentId: authStudent?.idEstudiante);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Al regresar a esta pantalla desde otra vista, se reproduce una sola vez de nuevo
    if (mounted) {
      setState(() {
        _lottieKey = UniqueKey();
      });
    }
  }

  void _replayLottie() {
    if (mounted) {
      setState(() {
        _lottieKey = UniqueKey();
      });
    }
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
                _replayLottie();
              },
              child: _LoadedState(
                vm: vm,
                lottieKey: _lottieKey,
                onRefreshLottie: _replayLottie,
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
  final Key lottieKey;
  final VoidCallback onRefreshLottie;
  final VoidCallback onLogout;
  final VoidCallback onShowProfile;

  const _LoadedState({
    required this.vm,
    required this.lottieKey,
    required this.onRefreshLottie,
    required this.onLogout,
    required this.onShowProfile,
  });

  @override
  Widget build(BuildContext context) {
    final resumen = vm.summary;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Fondo azul superior curvo con esferas difuminadas (mismo estilo del Login)
          Container(
            width: double.infinity,
            height: 245,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D2167),
                  Color(0xFF173899),
                  Color(0xFF2457D6),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(38),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(38),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -35,
                    left: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blueAccent.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20,
                    right: 40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.lightBlueAccent.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: -25,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF60A5FA).withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 35,
                    right: 110,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Superior en blanco sobre el fondo azul
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (drawerCtx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 28),
                        color: Colors.white,
                        tooltip: 'Menú de opciones',
                        onPressed: () => Scaffold.of(drawerCtx).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mis Cursos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hola, ${vm.primerNombre}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar interactivo
                    InkWell(
                      onTap: onShowProfile,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF142C73),
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
                    ),

                    const SizedBox(width: 4),

                    // Botón de Cerrar Sesión en Header
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      tooltip: 'Cerrar sesión',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tarjeta Hero con Lottie main.json a la derecha (reproduce una sola vez)
                _HeroCard(
                  key: lottieKey,
                  resumen: resumen,
                  totalCursos: vm.courses.length,
                ),

                const SizedBox(height: 18),

                // Barra de ordenamiento y última sincronización
                Row(
                  children: [
                    InkWell(
                      onTap: vm.toggleSort,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderOf(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_vert_rounded,
                              size: 16,
                              color: AppColors.textSecondaryOf(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              vm.sortByPriority ? 'Por prioridad de riesgo' : 'Alfabético',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondaryOf(context),
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
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RiskScreen(courseId: curso.idCurso),
                          ),
                        );
                        onRefreshLottie();
                      },
                    ),
                  ),
                ),
              ],
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

  const _HeroCard({
    super.key,
    required this.resumen,
    required this.totalCursos,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D3B91),
            Color(0xFF2349B5),
            Color(0xFF2D60DC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0xFF173899).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Brillo interior detrás del Lottie
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.lightBlueAccent.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 14, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Columna izquierda: Textos y estado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen Académico',
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mensaje,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (resumen.critico > 0)
                              _StatusPill(
                                icono: Icons.warning_rounded,
                                texto: '${resumen.critico} crítico',
                                color: const Color(0xFF991B1B),
                                fondo: const Color(0xFFFEE2E2),
                              ),
                            if (resumen.moderado > 0)
                              _StatusPill(
                                icono: Icons.trending_down_rounded,
                                texto: '${resumen.moderado} moderado',
                                color: const Color(0xFF92400E),
                                fondo: const Color(0xFFFEF3C7),
                              ),
                            _StatusPill(
                              icono: Icons.check_circle_rounded,
                              texto: '${resumen.bajo} seguro',
                              color: const Color(0xFF065F46),
                              fondo: const Color(0xFFD1FAE5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Animación Lottie a la derecha
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Lottie.asset(
                      'assets/animations/main.json',
                      fit: BoxFit.contain,
                      repeat: false,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.rocket_launch_rounded,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.85),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: fondo.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
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
