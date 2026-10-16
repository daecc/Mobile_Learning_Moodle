import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../screens/gamification_screen.dart';
import '../screens/login_screen.dart';
import '../screens/metacognitive_screen.dart';
import '../screens/tutor_screen.dart';

/// Barra de navegación lateral (Drawer) que consolida todos los módulos del sistema.
class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    this.currentRoute = 'courses',
  });

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
          '¿Estás seguro de que deseas salir de tu cuenta de Moodle? Tendrás que volver a ingresar tus credenciales.',
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
              Navigator.of(ctx).pop(); // Cierra diálogo
              Navigator.of(context).pop(); // Cierra drawer
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

  @override
  Widget build(BuildContext context) {
    final authStudent = context.watch<AuthViewModel>().student;
    final coursesVm = context.watch<CoursesViewModel>();
    final themeVm = context.watch<ThemeViewModel>();

    final nombreEstudiante = authStudent?.nombre ?? coursesVm.studentName;
    final codigoEstudiante = authStudent?.idEstudiante ?? coursesVm.studentId;
    final emailEstudiante = authStudent?.email ?? '$codigoEstudiante@unmsm.edu.pe';
    final iniciales = authStudent?.iniciales ?? coursesVm.iniciales;

    return Drawer(
      backgroundColor: AppColors.surfaceOf(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header del Drawer con perfil institucional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          iniciales,
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Chip indicador MoodleCloud
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_done_rounded, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'MoodleCloud',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nombreEstudiante,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emailEstudiante,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingeniería de Software · FISI UNMSM',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Opciones de Pantallas Consolidadas
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.school_rounded,
                    title: 'Mis Cursos y Riesgo',
                    subtitle: 'Dashboard principal de asignaturas',
                    isSelected: currentRoute == 'courses',
                    badgeText: '${coursesVm.courses.length}',
                    onTap: () {
                      Navigator.of(context).pop(); // Cierra drawer
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.insights_rounded,
                    title: 'Control Metacognitivo',
                    subtitle: 'Estrategia 4: Autorregulación',
                    isSelected: currentRoute == 'metacognitive',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MetacognitiveScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.smart_toy_rounded,
                    title: 'Tutor Inteligente IA',
                    subtitle: 'Componente IAG-ML adaptativo',
                    isSelected: currentRoute == 'tutor',
                    badgeText: 'IA',
                    badgeColor: AppColors.brand,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TutorScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Gamificación y Logros',
                    subtitle: 'Estrategia 5: Motivación y retos',
                    isSelected: currentRoute == 'gamification',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GamificationScreen()),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),

                  // Sección de Ajustes Rápidos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'PREFERENCIAS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMutedOf(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Toggle Modo Oscuro dentro del Drawer
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Icon(
                      themeVm.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: themeVm.isDarkMode ? Colors.amber : AppColors.brand,
                      size: 22,
                    ),
                    title: Text(
                      'Modo Oscuro',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    trailing: Switch(
                      value: themeVm.isDarkMode,
                      activeThumbColor: AppColors.brand,
                      onChanged: (_) => themeVm.toggleTheme(),
                    ),
                  ),

                  // Botón Cerrar Sesión
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.riskHigh,
                      size: 22,
                    ),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.riskHigh,
                      ),
                    ),
                    onTap: () => _confirmarCerrarSesion(context),
                  ),
                ],
              ),
            ),

            // Footer institucional
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderOf(context))),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMutedOf(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rumbo v1.0.0 · Mobile Learning & IA',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedOf(context),
                        fontWeight: FontWeight.w500,
                      ),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.badgeText,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.brand;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.brandSoftOf(context) : Colors.transparent,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brand : AppColors.brandSoftOf(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : activeColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            color: isSelected ? activeColor : AppColors.textPrimaryOf(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMutedOf(context),
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.brandSoftOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor != null ? Colors.white : activeColor,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
