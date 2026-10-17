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

/// Barra de navegación lateral (Drawer) rediseñada con estética móvil limpia y humana.
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
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.riskHigh, size: 22),
            const SizedBox(width: 10),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas salir de tu cuenta de Moodle? Tendrás que volver a autenticarte.',
          style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13.5),
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
              minimumSize: const Size(110, 40),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.read<AuthViewModel>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _mostrarTerminos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
            const SizedBox(height: 20),
            Text(
              'Términos y Privacidad de Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rumbo procesa tus registros académicos de Moodle exclusivamente con fines pedagógicos y de prevención del rezago en la UNMSM FISI. Tus credenciales de sesión se gestionan mediante tokens oficiales de Web Services y nunca se comparten con terceros.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
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
    final iniciales = authStudent?.iniciales ?? coursesVm.iniciales;

    return Drawer(
      backgroundColor: AppColors.surfaceOf(context),
      child: SafeArea(
        child: Column(
          children: [
            // Cabecera de Perfil Minimalista
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      iniciales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreEstudiante,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryOf(context),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'UNMSM · FISI',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                        Text(
                          codigoEstudiante,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.borderOf(context), height: 1),

            const SizedBox(height: 8),

            // Opciones de Navegación Limpias
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _CleanDrawerTile(
                    icon: Icons.book_outlined,
                    title: 'Mis Asignaturas',
                    isSelected: currentRoute == 'courses',
                    badge: '${coursesVm.courses.length}',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _CleanDrawerTile(
                    icon: Icons.smart_toy_outlined,
                    title: 'Tutor Inteligente',
                    isSelected: currentRoute == 'tutor',
                    badge: 'IA',
                    badgeColor: AppColors.neutralSoft,
                    badgeTextColor: AppColors.textPrimaryOf(context),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TutorScreen()),
                      );
                    },
                  ),
                  _CleanDrawerTile(
                    icon: Icons.insights_rounded,
                    title: 'Control Metacognitivo',
                    isSelected: currentRoute == 'metacognitive',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MetacognitiveScreen()),
                      );
                    },
                  ),
                  _CleanDrawerTile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Gamificación y Logros',
                    isSelected: currentRoute == 'gamification',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GamificationScreen()),
                      );
                    },
                  ),
                  _CleanDrawerTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Agenda y Entregas',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sincronizado: 2 entregas de MoodleCloud registradas'),
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Divider(color: AppColors.borderOf(context), height: 1),
                  ),

                  _CleanDrawerTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Ajustes y Notificaciones',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alertas automáticas de tareas activadas'),
                        ),
                      );
                    },
                  ),

                  // Modo Oscuro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: Icon(
                        themeVm.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        size: 20,
                        color: AppColors.textSecondaryOf(context),
                      ),
                      title: Text(
                        'Modo Oscuro',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      trailing: Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: themeVm.isDarkMode,
                          activeThumbColor: AppColors.brand,
                          onChanged: (_) => themeVm.toggleTheme(),
                        ),
                      ),
                    ),
                  ),

                  _CleanDrawerTile(
                    icon: Icons.description_outlined,
                    title: 'Términos y Privacidad',
                    onTap: () {
                      Navigator.of(context).pop();
                      _mostrarTerminos(context);
                    },
                  ),

                  _CleanDrawerTile(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar Sesión',
                    color: AppColors.riskHigh,
                    onTap: () => _confirmarCerrarSesion(context),
                  ),
                ],
              ),
            ),

            // Footer minimalista
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Rumbo v1.0 · UNMSM',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMutedOf(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanDrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Color? color;
  final VoidCallback onTap;

  const _CleanDrawerTile({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (isSelected ? AppColors.brand : AppColors.textPrimaryOf(context));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.brandSoftOf(context) : Colors.transparent,
        leading: Icon(
          icon,
          size: 20,
          color: color ?? (isSelected ? AppColors.brand : AppColors.textSecondaryOf(context)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: effectiveColor,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.brandSoftOf(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor ?? (badgeColor != null ? Colors.white : AppColors.brand),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
