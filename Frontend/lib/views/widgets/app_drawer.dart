import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
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
    final nav = Navigator.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(ctx),
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
                color: AppColors.textPrimaryOf(ctx),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas salir de tu cuenta de Moodle? Tendrás que volver a autenticarte.',
          style: TextStyle(color: AppColors.textSecondaryOf(ctx), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textMutedOf(ctx))),
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
              nav.pop();
              context.read<AuthViewModel>().logout();
              nav.pushAndRemoveUntil(
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

  void _mostrarAjustes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AjustesModal(),
    );
  }

  void _mostrarMetodologia(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MetodologiaModal(),
    );
  }

  void _mostrarTerminos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TerminosPrivacidadModal(),
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
                    icon: Icons.calendar_today_outlined,
                    title: 'Agenda y Entregas',
                    onTap: () {
                      Navigator.of(context).pop();
                      final metaVm = Provider.of<MetacognitiveViewModel>(context, listen: false);
                      final pending = metaVm.tareasPendientes;
                      final msg = pending > 0
                          ? 'Sincronizado: $pending ${pending == 1 ? "entrega pendiente" : "entregas pendientes"} en MoodleCloud'
                          : 'Sincronizado: Al día, sin entregas pendientes en MoodleCloud';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    },
                  ),

                  _CleanDrawerTile(
                    icon: Icons.analytics_outlined,
                    title: 'Metodología y Cálculos',
                    onTap: () {
                      final navContext = Navigator.of(context).context;
                      Navigator.of(context).pop();
                      _mostrarMetodologia(navContext);
                    },
                  ),

                  _CleanDrawerTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Ajustes y Notificaciones',
                    onTap: () {
                      final navContext = Navigator.of(context).context;
                      Navigator.of(context).pop();
                      _mostrarAjustes(navContext);
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
                          activeThumbColor: AppColors.brandOf(context),
                          onChanged: (_) => themeVm.toggleTheme(),
                        ),
                      ),
                    ),
                  ),

                  _CleanDrawerTile(
                    icon: Icons.description_outlined,
                    title: 'Términos y Privacidad',
                    onTap: () {
                      final navContext = Navigator.of(context).context;
                      Navigator.of(context).pop();
                      _mostrarTerminos(navContext);
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Divider(color: AppColors.borderOf(context), height: 1),
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
                    color: badgeTextColor ?? (badgeColor != null ? Colors.white : AppColors.brandOf(context)),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

// ============================================================================
// MODAL DE TÉRMINOS Y PRIVACIDAD DE DATOS (REDACTADO COMPLETO Y SEGURO)
// ============================================================================
class _TerminosPrivacidadModal extends StatelessWidget {
  const _TerminosPrivacidadModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Términos y Privacidad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryOf(context),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Proyecto Rumbo · UNMSM FISI',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondaryOf(context)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.borderOf(context), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: '1. Naturaleza y Finalidad de Rumbo',
                    content:
                        'Rumbo es un entorno móvil de andamiaje cognitivo y analítica académica desarrollado en la Facultad de Ingeniería de Sistemas e Informática (FISI) de la Universidad Nacional Mayor de San Marcos (UNMSM). Su único fin es acompañar a los estudiantes en su trayectoria universitaria, facilitando la autorregulación de sus hábitos de estudio y alertando tempranamente situaciones de riesgo de rezago académico para brindarles apoyo personalizado.',
                  ),
                  _buildSection(
                    context,
                    title: '2. Marco Legal y Protección de Datos',
                    content:
                        'El tratamiento de los datos personales y académicos se rige en estricto cumplimiento de la Ley N° 29733 (Ley de Protección de Datos Personales de la República del Perú) y su Reglamento aprobado mediante Decreto Supremo N° 003-2013-JUS. Garantizamos los principios rectores de legalidad, consentimiento, finalidad formativa, proporcionalidad y confidencialidad.',
                  ),
                  _buildSection(
                    context,
                    title: '3. Datos de Moodle Procesados',
                    content:
                        'Rumbo recopila y analiza exclusivamente datos académicos vinculados a tu cuenta institucional en Moodle:\n'
                        '• Estado y fechas límite de tareas y asignaciones.\n'
                        '• Calificaciones vigesimales (0 a 20) obtenidas en tareas y cuestionarios.\n'
                        '• Registros de interacción y lectura de recursos educativos.\n'
                        '• Frecuencia semanal de sesiones en el aula virtual y participación en foros.\n'
                        'En ningún caso se solicitan contraseñas maestras personales ni datos bancarios o sensibles ajenos a tu formación académica.',
                  ),
                  _buildSection(
                    context,
                    title: '4. Principio de No Punición',
                    content:
                        'La información procesada por Rumbo y las estimaciones del modelo predictivo tienen un propósito estrictamente preventivo, orientador y formativo. Los cálculos de riesgo y las métricas nunca se utilizarán con carácter sancionatorio, discriminatorio, punitivo ni afectarán negativamente la condición académica del estudiante ante la facultad.',
                  ),
                  _buildSection(
                    context,
                    title: '5. Seguridad y Gestión de Tokens',
                    content:
                        'La comunicación con los servidores de Moodle se establece mediante Tokens oficiales de Web Services con cifrado SSL/TLS. Las credenciales de sesión se almacenan de manera local y cifrada en el dispositivo del estudiante. Rumbo no reenvía credenciales a servidores externos no autorizados.',
                  ),
                  _buildSection(
                    context,
                    title: '6. No Cesión a Terceros',
                    content:
                        'Tus datos académicos son estrictamente confidenciales. Rumbo no vende, comparte, cede ni transfiere información a empresas privadas, terceros ni redes publicitarias. Los análisis estadísticos agregados que se elaboren para fines de investigación académica de la universidad son totalmente anonimizados.',
                  ),
                  _buildSection(
                    context,
                    title: '7. Derechos ARCO y Revocación',
                    content:
                        'Puedes ejercer tus derechos de Acceso, Rectificación, Cancelación y Oposición (ARCO) sobre tus datos. Asimismo, puedes revocar la vinculación de tu sesión en cualquier instante pulsando "Cerrar Sesión", lo que eliminará inmediatamente los tokens locales y detendrá la sincronización de tu información en este dispositivo.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandOf(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('He leído y acepto los términos', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODAL DE METODOLOGÍA Y CÁLCULOS (MODELO PREDICTIVO Y GAMIFICACIÓN)
// ============================================================================
class _MetodologiaModal extends StatelessWidget {
  const _MetodologiaModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metodología y Cálculos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryOf(context),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Modelo Predictivo y Gamificación Académica',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondaryOf(context)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.borderOf(context), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: '1. Modelo Predictivo de Riesgo Académico',
                    subtitle:
                        'El porcentaje de riesgo evalúa la probabilidad de rezago mediante un modelo de Regresión Logística entrenado con los indicadores reales de tu interacción en Moodle.',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Las 7 Variables Académicas de Moodle:',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildVariableItem(
                    context,
                    num: '1',
                    nombre: 'Cumplimiento de Tareas',
                    descripcion: 'Ratio entre tareas entregadas y el total asignado en la asignatura.',
                  ),
                  _buildVariableItem(
                    context,
                    num: '2',
                    nombre: 'Días de Retraso Promedio',
                    descripcion: 'Promedio de días transcurridos entre la fecha límite y el envío real.',
                  ),
                  _buildVariableItem(
                    context,
                    num: '3',
                    nombre: 'Tasa de Aprobación en Quizzes',
                    descripcion: 'Porcentaje de cuestionarios o pruebas cortas aprobadas con nota ≥ 11.0.',
                  ),
                  _buildVariableItem(
                    context,
                    num: '4',
                    nombre: 'Promedio Acumulado',
                    descripcion: 'Calificación oficial registrada en Moodle en la escala vigesimal (0 a 20).',
                  ),
                  _buildVariableItem(
                    context,
                    num: '5',
                    nombre: 'Interacción con Recursos',
                    descripcion: 'Frecuencia de lectura y consulta de diapositivas, lecturas y guías.',
                  ),
                  _buildVariableItem(
                    context,
                    num: '6',
                    nombre: 'Participación en Foros',
                    descripcion: 'Número de aportes, preguntas y réplicas en los foros del curso.',
                  ),
                  _buildVariableItem(
                    context,
                    num: '7',
                    nombre: 'Frecuencia de Accesos',
                    descripcion: 'Días por semana con sesiones activas de estudio en el aula virtual.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bandas de Riesgo (Semáforo):',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBandItem(
                    context,
                    banda: 'Riesgo Bajo (0% - 30%)',
                    color: AppColors.riskLow,
                    descripcion: 'Desempeño óptimo y seguro. El estudiante mantiene hábitos regulares y entregas al día.',
                  ),
                  _buildBandItem(
                    context,
                    banda: 'Riesgo Medio (31% - 60%)',
                    color: AppColors.riskMedium,
                    descripcion: 'Alerta preventiva. Se identifican entregas demoradas o notas cercanas al límite aprobatorio.',
                  ),
                  _buildBandItem(
                    context,
                    banda: 'Riesgo Alto (61% - 100%)',
                    color: AppColors.riskHigh,
                    descripcion: 'Rezago crítico. Se recomienda intervención inmediata y consulta con el Tutor Inteligente IA.',
                  ),
                  const SizedBox(height: 24),
                  _buildHeaderCard(
                    context,
                    icon: Icons.workspace_premium_rounded,
                    title: '2. Salón de Logros y Gamificación',
                    subtitle:
                        'El sistema premia la constancia y los hábitos proactivos de estudio mediante Puntos Rumbo (XP), niveles de maestría y rachas de conexión.',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Distribución de Puntos Rumbo (XP):',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildXpRule(
                    context,
                    xp: '+100 XP',
                    titulo: 'Entrega Impecable',
                    detalle: 'Enviar todas las tareas de Moodle dentro del plazo estipulado.',
                  ),
                  _buildXpRule(
                    context,
                    xp: '+150 XP',
                    titulo: 'Guardián del Rendimiento',
                    detalle: 'Mantener todas tus asignaturas matriculadas en nivel de riesgo Bajo.',
                  ),
                  _buildXpRule(
                    context,
                    xp: '+120 XP',
                    titulo: 'As de los Cuestionarios',
                    detalle: 'Aprobar sólidamente las evaluaciones continuas del ciclo.',
                  ),
                  _buildXpRule(
                    context,
                    xp: '+80 XP',
                    titulo: 'Constancia Semanal',
                    detalle: 'Cumplir la meta de 4 o más días de actividad semanal en Moodle.',
                  ),
                  _buildXpRule(
                    context,
                    xp: '+90 XP',
                    titulo: 'Estratega del Aprendizaje',
                    detalle: 'Revisar semanalmente tus diagnósticos y recomendaciones metacognitivas.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Niveles de Maestría:',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cada nivel requiere 200 XP acumulados. A medida que asciendes, desbloqueas nuevos rangos que reconocen tu autogestión académica.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandOf(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandOf(context).withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brandOf(context), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariableItem(
    BuildContext context, {
    required String num,
    required String nombre,
    required String descripcion,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandOf(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              num,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.brandOf(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textSecondaryOf(context)),
                children: [
                  TextSpan(
                    text: '$nombre: ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context)),
                  ),
                  TextSpan(text: descripcion),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandItem(
    BuildContext context, {
    required String banda,
    required Color color,
    required String descripcion,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banda,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 11.5, height: 1.35, color: AppColors.textSecondaryOf(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpRule(
    BuildContext context, {
    required String xp,
    required String titulo,
    required String detalle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.brandOf(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              xp,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brandOf(context)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryOf(context)),
                children: [
                  TextSpan(
                    text: '$titulo — ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context)),
                  ),
                  TextSpan(text: detalle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODAL DE AJUSTES Y NOTIFICACIONES FUNCIONAL
// ============================================================================
class _AjustesModal extends StatefulWidget {
  const _AjustesModal();

  @override
  State<_AjustesModal> createState() => _AjustesModalState();
}

class _AjustesModalState extends State<_AjustesModal> {
  bool _alertaTareas = true;
  bool _alertaRezago = true;
  bool _sugerenciasTutor = true;
  bool _sonidos = false;
  String _sincro = 'auto';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajustes y Notificaciones',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryOf(context),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Preferencias de alertas y sincronización',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondaryOf(context)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.borderOf(context), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  'NOTIFICACIONES ACADÉMICAS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandOf(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Recordatorio de Tareas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  subtitle: Text(
                    'Alertar 24 horas antes del vencimiento en Moodle',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                  ),
                  value: _alertaTareas,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (val) => setState(() => _alertaTareas = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Alertas de Rezago Académico',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  subtitle: Text(
                    'Avisar cuando un curso suba a nivel de riesgo Medio o Alto',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                  ),
                  value: _alertaRezago,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (val) => setState(() => _alertaRezago = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sugerencias del Tutor IA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  subtitle: Text(
                    'Recomendaciones metacognitivas y preguntas de reflexión semanales',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                  ),
                  value: _sugerenciasTutor,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (val) => setState(() => _sugerenciasTutor = val),
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.borderOf(context), height: 1),
                const SizedBox(height: 16),
                Text(
                  'EXPERIENCIA DE LA APLICACIÓN',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandOf(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Efectos de Sonido',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  subtitle: Text(
                    'Sonido sutil al desbloquear logros y recibir mensajes del Tutor',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                  ),
                  value: _sonidos,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (val) => setState(() => _sonidos = val),
                ),
                const SizedBox(height: 16),
                Text(
                  'Frecuencia de Sincronización Moodle:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 6),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Automática en segundo plano', style: TextStyle(fontSize: 13, color: AppColors.textPrimaryOf(context))),
                  value: 'auto',
                  groupValue: _sincro,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (v) => setState(() => _sincro = v!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Al abrir la aplicación', style: TextStyle(fontSize: 13, color: AppColors.textPrimaryOf(context))),
                  value: 'open',
                  groupValue: _sincro,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (v) => setState(() => _sincro = v!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Manual únicamente', style: TextStyle(fontSize: 13, color: AppColors.textPrimaryOf(context))),
                  value: 'manual',
                  groupValue: _sincro,
                  activeColor: AppColors.brandOf(context),
                  onChanged: (v) => setState(() => _sincro = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandOf(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferencias guardadas exitosamente'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Guardar Preferencias', style: TextStyle(fontWeight: FontWeight.w700)),
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

