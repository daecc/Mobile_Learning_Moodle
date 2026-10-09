import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/auth/auth_provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/courses/courses_viewmodel.dart';
import 'package:mlearning_early_warning/presentation/views/risk_detail/risk_detail_view.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/data/models/course/course_model.dart';

/// Dashboard principal: "Mis Cursos" (Home).
///
/// Muestra grid de tarjetas de cursos matriculados con:
/// - Info básica: código, nombre, docente, créditos
/// - Progreso visual (barra circular)
/// - Badge de estado (activo/finalizado)
/// - Tareas pendientes
/// - Navegación a RiskDetailView al tocar
///
/// Pull-to-refresh para actualizar.
class CoursesDashboardView extends StatefulWidget {
  const CoursesDashboardView({super.key});

  @override
  State<CoursesDashboardView> createState() => _CoursesDashboardViewState();
}

class _CoursesDashboardViewState extends State<CoursesDashboardView> {
  @override
  void initState() {
    super.initState();
    // Cargar cursos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesViewModel>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoursesViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context, vm),
      body: _buildBody(context, vm),
      floatingActionButton: _buildFab(context),
    );
  }

  /// AppBar con saludo, créditos totales y acciones
  PreferredSizeWidget _buildAppBar(BuildContext context, CoursesViewModel vm) {
    final authProvider = context.read<AuthProvider>();

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Cursos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceColor,
                ),
          ),
          if (authProvider.user != null)
            Text(
              '${authProvider.userDisplayName} • ${vm.totalCreditos} créditos',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
            ),
        ],
      ),
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.onSurfaceColor,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Badge de notificaciones (tareas pendientes totales)
        _NotificationBadge(count: vm.coursesWithPendingTasks.length),
        const SizedBox(width: 8),
        // Botón refresh
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: vm.isLoading ? null : () => vm.refresh(),
          tooltip: 'Actualizar',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Cuerpo principal con estados
  Widget _buildBody(BuildContext context, CoursesViewModel vm) {
    if (vm.isLoading && vm.courses.isEmpty) {
      return _buildLoadingState();
    }
    if (vm.hasError) {
      return _buildErrorState(vm.errorMessage!, vm.refresh);
    }
    if (vm.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Resumen rápido
          _buildSummarySliver(context, vm),
          // Grid de cursos
          _buildCoursesGrid(context, vm),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Espacio FAB
        ],
      ),
    );
  }

  /// Loading skeleton
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando tus cursos...',
            style: TextStyle(color: AppTheme.onSurfaceVariantColor),
          ),
        ],
      ),
    );
  }

  /// Estado error
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los cursos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío (sin matrículas)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: AppTheme.outlineColor),
            const SizedBox(height: 16),
            Text(
              'No tienes cursos matriculados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando te matricules en cursos, aparecerán aquí.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Sliver con resumen: chips de filtros y estadísticas
  Widget _buildSummarySliver(BuildContext context, CoursesViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips de filtro rápido
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos (${vm.courses.length})',
                    selected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Activos (${vm.activeCourses.length})',
                    selected: false,
                    onTap: () {},
                    icon: Icons.play_circle_rounded,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Finalizados (${vm.finishedCourses.length})',
                    selected: false,
                    onTap: () {},
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  if (vm.coursesWithPendingTasks.isNotEmpty)
                    _FilterChip(
                      label: 'Con tareas (${vm.coursesWithPendingTasks.length})',
                      selected: false,
                      onTap: () {},
                      icon: Icons.assignment_late_rounded,
                      color: AppTheme.warningColor,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(
                  label: 'Cursos activos',
                  value: vm.activeCourses.length.toString(),
                  icon: Icons.play_circle_rounded,
                  color: AppTheme.successColor,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Créditos',
                  value: vm.totalCreditos.toString(),
                  icon: Icons.school_rounded,
                  color: AppTheme.primaryColor,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Tareas pend.',
                  value: vm.coursesWithPendingTasks.fold(0, (sum, e) => sum + (e.tareasPendientes ?? 0)).toString(),
                  icon: Icons.assignment_rounded,
                  color: AppTheme.warningColor,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Grid de tarjetas de cursos
  Widget _buildCoursesGrid(BuildContext context, CoursesViewModel vm) {
    final courses = vm.courses;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final enrollment = courses[index];
            return _CourseCard(
              enrollment: enrollment,
              onTap: () => _navigateToRiskDetail(enrollment.course),
            );
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  /// Navega al detalle de riesgo del curso
  void _navigateToRiskDetail(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RiskDetailView(
          courseId: course.id,
          courseName: course.nombre,
        ),
      ),
    );
  }

  /// FAB para búsqueda rápida (futuro)
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: Navegar a búsqueda de catálogo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Catálogo de cursos próximamente'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      icon: const Icon(Icons.search_rounded),
      label: const Text('Explorar catálogo'),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: AppTheme.onPrimaryColor,
    );
  }
}

/// Chip de filtro en AppBar
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? Colors.white : chipColor),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : chipColor,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

/// Tarjeta de estadística
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de curso en el grid
class _CourseCard extends StatelessWidget {
  final CourseEnrollment enrollment;
  final VoidCallback onTap;

  const _CourseCard({
    required this.enrollment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final progreso = enrollment.progresoPorcentaje ?? 0.0;
    final tareas = enrollment.tareasPendientes ?? 0;
    final isActive = enrollment.estado == 'activo';

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: course.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con color del curso
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    course.color,
                    course.color.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(course.icon, color: Colors.white, size: 22),
                  const Spacer(),
                  _StatusBadge(isActive: isActive),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Código
                    Text(
                      course.codigo,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: course.color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // Nombre
                    Text(
                      course.nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceColor,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Docente
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: AppTheme.onSurfaceVariantColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.docente,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.onSurfaceVariantColor,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Créditos
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.creditos} créditos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onSurfaceVariantColor,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Progreso + tareas
                    _ProgressRow(
                      progreso: progreso,
                      tareasPendientes: tareas,
                      color: course.color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de estado (activo/finalizado)
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? 'ACTIVO' : 'FINALIZADO',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Fila de progreso inferior
class _ProgressRow extends StatelessWidget {
  final double progreso;
  final int tareasPendientes;
  final Color color;

  const _ProgressRow({
    required this.progreso,
    required this.tareasPendientes,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso / 100,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${progreso.toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        if (tareasPendientes > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.assignment_late_rounded,
                size: 13,
                color: AppTheme.warningColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$tareasPendientes tarea${tareasPendientes > 1 ? 's' : ''} pendiente${tareasPendientes > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Badge de notificaciones en AppBar
class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {
            // TODO: Navegar a pantalla de notificaciones/tareas
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}