import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/auth/auth_provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/courses/courses_viewmodel.dart';
import 'package:mlearning_early_warning/presentation/views/courses/courses_dashboard_view.dart';
import 'package:mlearning_early_warning/presentation/views/risk_detail/risk_detail_view.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/data/models/auth/user_model.dart';
import 'package:mlearning_early_warning/data/models/course/course_model.dart';

/// Navegación principal con BottomNavigationBar.
///
/// Estructura:
/// - Tab 0: Inicio / Mis Cursos (CoursesDashboardView)
/// - Tab 1: Alertas / Riesgo (RiskDetailView - requiere curso seleccionado)
/// - Tab 2: Perfil / Configuración (Placeholder)
///
/// Cada tab mantiene su propio NavigationStack (IndexedStack).
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _navigatorKeys = List.generate(
      3,
      (index) => GlobalKey<NavigatorState>(),
    );
    _tabs = _buildTabs();
  }

  List<Widget> _buildTabs() {
    return [
      // Tab 0: Inicio - Mis Cursos
      _TabNavigator(
        navigatorKey: _navigatorKeys[0],
        child: const CoursesDashboardView(),
      ),
      // Tab 1: Alertas - Riesgo Académico
      _TabNavigator(
        navigatorKey: _navigatorKeys[1],
        child: const _AlertasTab(),
      ),
      // Tab 2: Perfil
      _TabNavigator(
        navigatorKey: _navigatorKeys[2],
        child: const _PerfilTab(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider se usa en _AuthGate (main.dart) para decidir si mostrar esta vista
    context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handleBackButton(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  /// Maneja botón atrás: pop en navigator del tab actual o salir de app
  Future<bool> _handleBackButton() async {
    final navigator = _navigatorKeys[_currentIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false; // No salir de la app
    }
    // Si está en tab 0 (inicio) y no puede pop, salir
    if (_currentIndex == 0) {
      return true; // Permitir salida
    }
    // Si está en otro tab, ir a inicio
    setState(() => _currentIndex = 0);
    return false;
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.onSurfaceVariantColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
              tooltip: 'Mis Cursos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber_rounded),
              label: 'Alertas',
              tooltip: 'Riesgo Académico',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
              tooltip: 'Mi Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigator por tab para mantener stack independiente
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({
    required this.navigatorKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => child,
        settings: settings,
      ),
    );
  }
}

/// Tab de Alertas: Muestra lista de cursos con riesgo o permite seleccionar uno
class _AlertasTab extends StatelessWidget {
  const _AlertasTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final coursesVm = context.watch<CoursesViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Alertas de Riesgo'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: _buildBody(context, authProvider, coursesVm),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider authProvider, CoursesViewModel coursesVm) {
    if (coursesVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (coursesVm.isEmpty) {
      return _buildEmptyState(context);
    }

    // Filtrar cursos con riesgo medio/alto
    final cursosConRiesgo = coursesVm.courses.where((e) {
      // En producción, obtendríamos el riesgo real del modelo
      // Por ahora, simulamos basado en progreso y tareas
      return (e.progresoPorcentaje ?? 0) < 60 || (e.tareasPendientes ?? 0) > 2;
    }).toList();

    if (cursosConRiesgo.isEmpty) {
      return _buildNoRiskState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cursosConRiesgo.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final enrollment = cursosConRiesgo[index];
        return _RiskAlertCard(
          enrollment: enrollment,
          onTap: () => _navigateToRiskDetail(context, enrollment.course),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined, size: 80, color: AppTheme.outlineColor),
            const SizedBox(height: 16),
            Text(
              'No hay cursos cargados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ve a la pestaña Inicio para ver tus cursos.',
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

  Widget _buildNoRiskState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 80, color: AppTheme.successColor),
            const SizedBox(height: 16),
            Text(
              '¡Todo bajo control!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se detectan riesgos académicos en tus cursos actuales.',
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

  void _navigateToRiskDetail(BuildContext context, Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RiskDetailView(
          courseId: course.id,
          courseName: course.nombre,
        ),
      ),
    );
  }
}

/// Tarjeta de alerta de riesgo en la lista
class _RiskAlertCard extends StatelessWidget {
  final CourseEnrollment enrollment;
  final VoidCallback onTap;

  const _RiskAlertCard({
    required this.enrollment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final progreso = enrollment.progresoPorcentaje ?? 0.0;
    final tareas = enrollment.tareasPendientes ?? 0;

    // Determinar nivel de riesgo simulado
    final bool altoRiesgo = progreso < 40 || tareas > 3;
    final Color riesgoColor = altoRiesgo ? AppTheme.errorColor : AppTheme.warningColor;
    final String riesgoLabel = altoRiesgo ? 'Alto riesgo' : 'Riesgo medio';

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riesgoColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de color
              Container(
                width: 8,
                height: 60,
                decoration: BoxDecoration(
                  color: riesgoColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              // Info del curso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: course.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(course.icon, color: course.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.codigo,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: course.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                course.nombre,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Badge de riesgo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: riesgoColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: riesgoColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            altoRiesgo ? Icons.error_rounded : Icons.warning_amber_rounded,
                            size: 14,
                            color: riesgoColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            riesgoLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: riesgoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Detalles
                    Text(
                      'Progreso: ${progreso.toInt()}% • $tareas tarea${tareas > 1 ? 's' : ''} pendiente${tareas > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariantColor,
                          ),
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.onSurfaceVariantColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab de Perfil (Placeholder)
class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // TODO: Navegar a configuración
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No autenticado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar y datos
                  _ProfileHeader(user: user),
                  const SizedBox(height: 24),
                  // Estadísticas académicas
                  _ProfileStats(),
                  const SizedBox(height: 24),
                  // Opciones
                  _ProfileOptions(onLogout: () => authProvider.logout()),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar con iniciales
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                user.iniciales,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.nombreCompleto,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
            ),
            const SizedBox(height: 12),
            // Chips de info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _InfoChip(icon: Icons.school_rounded, label: user.programaEstudios),
                _InfoChip(icon: Icons.numbers_rounded, label: user.userCycle),
                _InfoChip(icon: Icons.apartment_rounded, label: user.facultad),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatItem(label: 'Cursos activos', value: '5', icon: Icons.play_circle_rounded, color: AppTheme.successColor)),
        Expanded(child: _StatItem(label: 'Créditos', value: '19', icon: Icons.star_rounded, color: AppTheme.warningColor)),
        Expanded(child: _StatItem(label: 'Promedio', value: '13.2', icon: Icons.trending_up_rounded, color: AppTheme.primaryColor)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariantColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfileOptions extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileOptions({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final options = <Widget>[
      _ProfileOptionTile(
        icon: Icons.help_outline_rounded,
        title: 'Ayuda y soporte',
        subtitle: 'Preguntas frecuentes y contacto',
        onTap: () {},
      ),
      _ProfileOptionTile(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacidad y datos',
        subtitle: 'Gestión de datos personales',
        onTap: () {},
      ),
      _ProfileOptionTile(
        icon: Icons.notifications_outlined,
        title: 'Notificaciones',
        subtitle: 'Configurar alertas y recordatorios',
        onTap: () {},
      ),
      _ProfileOptionTile(
        icon: Icons.dark_mode_outlined,
        title: 'Tema oscuro',
        subtitle: 'Cambiar apariencia de la app',
        onTap: () {},
      ),
      const Divider(),
      _ProfileOptionTile(
        icon: Icons.logout_rounded,
        title: 'Cerrar sesión',
        subtitle: 'Salir de mi cuenta',
        onTap: onLogout,
        isDestructive: true,
      ),
    ];

    return Column(children: options);
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.errorColor : AppTheme.onSurfaceVariantColor),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : AppTheme.onSurfaceColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 12)),
      trailing: isDestructive ? null : Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}