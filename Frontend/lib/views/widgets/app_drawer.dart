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
    final emailEstudiante = authStudent?.email ?? '$codigoEstudiante@unmsm.edu.pe';
    final iniciales = authStudent?.iniciales ?? coursesVm.iniciales;

    return Drawer(
      backgroundColor: AppColors.surfaceOf(context),
      child: SafeArea(
        child: Column(
          children: [
            // Tarjeta de Perfil Flotante Superior
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundOf(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderOf(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      iniciales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreEstudiante,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                        Text(
                          emailEstudiante,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMutedOf(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brandSoftOf(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'UNMSM FISI · 9no Ciclo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
                    title: 'Tutor Inteligente IA',
                    isSelected: currentRoute == 'tutor',
                    badge: 'IA',
                    badgeColor: AppColors.brand,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TutorScreen()),
                      );
                    },
                  ),
                  _CleanDrawerTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Plan y Horarios de Estudio',
                    isSelected: currentRoute == 'metacognitive',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MetacognitiveScreen()),
                      );
                    },
                  ),
                  _CleanDrawerTile(
                    icon: Icons.military_tech_outlined,
                    title: 'Logros y Metas',
                    isSelected: currentRoute == 'gamification',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GamificationScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Divider(color: AppColors.borderOf(context), height: 1),
                  ),

                  // Ajustes y Preferencias
                  _CleanDrawerTile(
                    icon: Icons.tune_rounded,
                    title: 'Ajustes y Notificaciones',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificaciones activas para entregas de Moodle')),
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
                        color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
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

                  // Términos y Condiciones
                  _CleanDrawerTile(
                    icon: Icons.description_outlined,
                    title: 'Términos y Privacidad',
                    onTap: () {
                      Navigator.of(context).pop();
                      _mostrarTerminos(context);
                    },
                  ),

                  // Cerrar Sesión
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Rumbo Mobile v1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMutedOf(context),
                  fontWeight: FontWeight.w500,
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
  final Color? color;
  final VoidCallback onTap;

  const _CleanDrawerTile({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.badge,
    this.badgeColor,
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
                    color: badgeColor != null ? Colors.white : AppColors.brand,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
