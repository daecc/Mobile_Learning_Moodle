import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gamification_tier.dart';
import '../../data/services/sync_coordinator.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/tutor_viewmodel.dart';
import '../widgets/app_drawer.dart';

/// Modelo de datos para representar un logro en la interfaz.
class AchievementItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'moodle', 'tutor', 'habits'
  final IconData icon;
  final Color iconColor;
  final int currentProgress;
  final int maxProgress;
  final int xpReward;
  final bool isUnlocked;
  final String? dateUnlocked;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.currentProgress,
    required this.maxProgress,
    required this.xpReward,
    required this.isUnlocked,
    this.dateUnlocked,
  });

  double get percent => (currentProgress / maxProgress).clamp(0.0, 1.0);
}

/// Pantalla de Gamificación y Logros (Opción 2: Salón de Trofeos y Maestría).
class GamificationScreen extends StatefulWidget {
  final bool isTab;

  const GamificationScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  String _selectedCategory = 'all'; // 'all', 'moodle', 'tutor', 'habits'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppSyncCoordinator.reloadLocalState(context);
      }
    });
  }

  void _mostrarReglasGamificacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReglasGamificacionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final coursesVm = context.watch<CoursesViewModel>();
    final authStudent = context.watch<AuthViewModel>().student;
    final metacognitiveVm = context.watch<MetacognitiveViewModel>();
    final tutorVm = context.watch<TutorViewModel>();

    final studentName = authStudent?.nombre ?? coursesVm.studentName;
    final totalCursos = coursesVm.courses.length;
    final safeCourses = coursesVm.courses.where((c) => c.nivelRiesgo == 'BAJO').length;
    final cursosRevisadosCount = metacognitiveVm.cursosRevisadosEstaSemana.length;
    final esEstratega = totalCursos > 0 && cursosRevisadosCount >= totalCursos;

    // Métricas reales extraídas en vivo desde Moodle y el Tutor IA
    final tareasTotales = metacognitiveVm.tareasTotales;
    final tareasEntregadas = metacognitiveVm.tareasEntregadas;
    final diasActivos = metacognitiveVm.diasActivosSemanales;
    final tutorConsultas = tutorVm.mensajes.where((m) => m.esUsuario).length;

    // Promedio ponderado en evaluaciones obtenido en Moodle según los créditos de cada curso
    double sumaNotasPonderadas = 0.0;
    int sumaCreditosConNota = 0;

    for (final c in metacognitiveVm.cursos) {
      final prom = c.metricas.where((m) => m.clave == 'promedio').firstOrNull;
      if (prom == null || prom.valor == 'Sin notas') continue;
      final nota = double.tryParse(prom.valor);
      if (nota != null) {
        final creditos = c.curso.creditos > 0 ? c.curso.creditos : 4;
        sumaNotasPonderadas += nota * creditos;
        sumaCreditosConNota += creditos;
      }
    }

    final double promedioPonderado = sumaCreditosConNota > 0
        ? (sumaNotasPonderadas / sumaCreditosConNota)
        : 0.0;
    final bool tieneBuenPromedio =
        sumaCreditosConNota > 0 && promedioPonderado >= 14.0;

    // Lista de logros académicos conectados a la realidad del estudiante
    final allAchievements = [
      AchievementItem(
        id: 'entrega_impecable',
        title: 'Entrega Impecable',
        description: tareasTotales == 0
            ? 'Al día: no registras tareas pendientes en Moodle.'
            : 'Envía todas tus tareas en Moodle antes de la fecha límite ($tareasEntregadas de $tareasTotales entregadas).',
        category: 'moodle',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: tareasTotales == 0 ? 1 : tareasEntregadas,
        maxProgress: tareasTotales == 0 ? 1 : tareasTotales,
        xpReward: 100,
        isUnlocked: tareasTotales == 0 || tareasEntregadas >= tareasTotales,
        dateUnlocked: (tareasTotales == 0 || tareasEntregadas >= tareasTotales) ? 'Al día' : null,
      ),
      AchievementItem(
        id: 'zona_segura',
        title: 'Guardián del Rendimiento',
        description: totalCursos == 0
            ? 'No hay cursos matriculados aún.'
            : 'Mantén todos tus cursos matriculados en nivel de riesgo Bajo ($safeCourses de $totalCursos seguros).',
        category: 'habits',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: safeCourses,
        maxProgress: totalCursos > 0 ? totalCursos : 1,
        xpReward: 150,
        isUnlocked: totalCursos > 0 && safeCourses >= totalCursos,
        dateUnlocked: (totalCursos > 0 && safeCourses >= totalCursos) ? 'Activo' : null,
      ),
      AchievementItem(
        id: 'maestro_quiz',
        title: 'As de los Cuestionarios',
        description: sumaCreditosConNota > 0
            ? (tieneBuenPromedio
                ? '¡Meta lograda! Promedio ponderado destacado en cuestionarios (${promedioPonderado.toStringAsFixed(1)}/20 en el ciclo).'
                : 'Requiere promedio ponderado destacado (≥ 14.0) en cuestionarios (Tu promedio ponderado actual: ${promedioPonderado.toStringAsFixed(1)}/20).')
            : 'Obtén promedio ponderado destacado (≥ 14.0) en tus cuestionarios de Moodle.',
        category: 'moodle',
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFFD97706),
        currentProgress: tieneBuenPromedio ? 1 : 0,
        maxProgress: 1,
        xpReward: 120,
        isUnlocked: tieneBuenPromedio,
        dateUnlocked: tieneBuenPromedio ? 'Ciclo actual' : null,
      ),
      AchievementItem(
        id: 'racha_academica',
        title: 'Constancia Semanal',
        description: diasActivos >= 4
            ? '¡Meta lograda! Cumples con la meta recomendada de 4 días de actividad semanal ($diasActivos de 4 días).'
            : 'Cumple la meta recomendada de 4 días de actividad semanal en el aula virtual ($diasActivos de 4 días).',
        category: 'habits',
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFD97706),
        currentProgress: diasActivos.clamp(0, 4),
        maxProgress: 4,
        xpReward: 80,
        isUnlocked: diasActivos >= 4,
        dateUnlocked: diasActivos >= 4 ? 'Esta semana' : null,
      ),
      AchievementItem(
        id: 'feedback_activo',
        title: 'Estratega del Aprendizaje',
        description: totalCursos == 0
            ? 'No tienes cursos matriculados aún.'
            : (esEstratega
                ? '¡Meta lograda! Has revisado el diagnóstico predictivo de todos tus cursos ($cursosRevisadosCount de $totalCursos revisados esta semana).'
                : 'Revisa el diagnóstico detallado («¿Por qué este resultado?») de cada curso ($cursosRevisadosCount de $totalCursos revisados esta semana).'),
        category: 'tutor',
        icon: Icons.insights_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: totalCursos == 0 ? 0 : cursosRevisadosCount.clamp(0, totalCursos),
        maxProgress: totalCursos > 0 ? totalCursos : 1,
        xpReward: 90,
        isUnlocked: esEstratega,
        dateUnlocked: esEstratega ? 'Esta semana' : null,
      ),
      AchievementItem(
        id: 'curioso_digital',
        title: 'Mente Inquisitiva',
        description: tutorConsultas >= 3
            ? '¡Meta lograda! Has realizado al menos 3 consultas reflexivas al Tutor IA ($tutorConsultas de 3 consultas).'
            : 'Realiza consultas reflexivas con el Tutor Inteligente IA ($tutorConsultas de 3 consultas realizadas).',
        category: 'tutor',
        icon: Icons.psychology_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: tutorConsultas.clamp(0, 3),
        maxProgress: 3,
        xpReward: 100,
        isUnlocked: tutorConsultas >= 3,
        dateUnlocked: tutorConsultas >= 3 ? 'Reciente' : null,
      ),
    ];

    final filteredAchievements = _selectedCategory == 'all'
        ? allAchievements
        : allAchievements.where((a) => a.category == _selectedCategory).toList();

    final unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
    final pointsSummary = GamificationPointsSummary.calculate(
      tareasEntregadas: tareasEntregadas,
      safeCourses: safeCourses,
      totalCursos: totalCursos,
      tareasTotales: tareasTotales,
      tieneBuenPromedio: tieneBuenPromedio,
      diasActivosSemanales: diasActivos,
      esEstrategaEstaSemana: esEstratega,
      semanasPreviasEstratega: metacognitiveVm.semanasPreviasEstratega,
      semanasPreviasConstancia: metacognitiveVm.semanasPreviasConstancia,
      tutorConsultas: tutorConsultas,
    );

    final totalPoints = pointsSummary.totalPoints;
    final tier = pointsSummary.tier;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      drawer: const AppDrawer(currentRoute: 'gamification'),
      body: RefreshIndicator(
        onRefresh: () => AppSyncCoordinator.syncAll(context),
        color: AppColors.brandOf(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: widget.isTab ? 100 : 32),
          child: Column(
          children: [
            // ==========================================
            // HEADER HERO CURVO CON ESPACIO LOTTIE
            // ==========================================
            _buildHeroHeader(
              context: context,
              themeVm: themeVm,
              studentName: studentName,
              totalPoints: totalPoints,
              tier: tier,
              onMostrarReglas: () => _mostrarReglasGamificacion(context),
            ),

            // ==========================================
            // MÉTRICAS RÁPIDAS (PÍLDORA GLASSCARD)
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickStatsCard(
                  context: context,
                  rachaDias: diasActivos,
                  medallasDesbloqueadas: '$unlockedCount/${allAchievements.length}',
                  cursosSeguros: '$safeCourses/$totalCursos',
                ),
              ),
            ),

            // ==========================================
            // BARRA DE NIVEL Y PROGRESO XP
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: _buildLevelProgressCard(
                context,
                pointsSummary: pointsSummary,
                onMostrarReglas: () => _mostrarReglasGamificacion(context),
              ),
            ),

            // ==========================================
            // FILTROS POR CATEGORÍA
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Salón de Logros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandOf(context).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.brandOf(context)),
                        const SizedBox(width: 4),
                        Text(
                          '$unlockedCount Obtenidos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildCategorySelector(context),
            const SizedBox(height: 16),

            // ==========================================
            // LISTA DE TARJETAS DE LOGRO
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredAchievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredAchievements[index];
                  return _buildAchievementCard(context, item);
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    ),
  );
}

  /// Header superior curvo azul con diseño similar a Mis Cursos
  Widget _buildHeroHeader({
    required BuildContext context,
    required ThemeViewModel themeVm,
    required String studentName,
    required int totalPoints,
    required GamificationTier tier,
    VoidCallback? onMostrarReglas,
  }) {
    final rangoTexto = 'Rango: Nivel ${tier.level} · ${tier.title}';

    return Container(
      width: double.infinity,
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
            // Esferas difuminadas decorativas de fondo (estilo bokeh)
            Positioned(
              top: -30,
              left: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF60A5FA).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Contenido del Header
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                child: Column(
                  children: [
                    // Fila superior: Título y botón de tema
                    Row(
                      children: [
                        if (!widget.isTab)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        else
                          Builder(
                            builder: (drawerCtx) => IconButton(
                              icon: const Icon(Icons.menu_rounded, size: 28),
                              color: Colors.white,
                              tooltip: 'Menú de opciones',
                              onPressed: () => Scaffold.of(drawerCtx).openDrawer(),
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gamificación',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Tus metas y reconocimientos académicos',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón de Reglas del Juego e información
                        IconButton(
                          onPressed: onMostrarReglas,
                          icon: const Icon(
                            Icons.help_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Reglas del juego y recompensas',
                        ),
                        // Botón de alternar tema
                        IconButton(
                          onPressed: () => themeVm.toggleTheme(),
                          icon: Icon(
                            themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: themeVm.isDarkMode ? Colors.amber : Colors.white70,
                          ),
                          tooltip: themeVm.isDarkMode ? 'Modo claro' : 'Modo oscuro',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ============================================================
                    // ESPACIO RESERVADO PARA TU ANIMACIÓN LOTTIE DEL TROFEO / COPA
                    // Reemplaza o asigna el path de tu Lottie cuando lo tengas.
                    // ============================================================
                    _buildLottieSlot(),

                    const SizedBox(height: 12),

                    // Título de Puntos y Rango
                    Text(
                      '$totalPoints Puntos Rumbo',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tier.icon, size: 14, color: Colors.amber.shade200),
                          const SizedBox(width: 6),
                          Text(
                            rangoTexto,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade200,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
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

  /// Renderiza la animación Lottie del logro / trofeo
  Widget _buildLottieSlot() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Lottie.asset(
        'assets/animations/logros.json',
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 40,
              color: Color(0xFFFDE68A),
            ),
          ),
        ),
      ),
    );
  }

  /// Tarjeta de 3 métricas rápidas (Racha, Medallas, Cursos Seguros)
  Widget _buildQuickStatsCard({
    required BuildContext context,
    required int rachaDias,
    required String medallasDesbloqueadas,
    required String cursosSeguros,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = AppColors.brandOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : AppColors.borderOf(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStatItem(
            context: context,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFD97706),
            title: '$rachaDias Días',
            subtitle: 'Racha Activa',
          ),
          Container(
            width: 1,
            height: 38,
            color: AppColors.borderOf(context),
          ),
          _buildQuickStatItem(
            context: context,
            icon: Icons.workspace_premium_rounded,
            iconColor: brand,
            title: medallasDesbloqueadas,
            subtitle: 'Medallas',
          ),
          Container(
            width: 1,
            height: 38,
            color: AppColors.borderOf(context),
          ),
          _buildQuickStatItem(
            context: context,
            icon: Icons.shield_rounded,
            iconColor: brand,
            title: cursosSeguros,
            subtitle: 'Zona Segura',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMutedOf(context),
          ),
        ),
      ],
    );
  }

  /// Barra de nivel con progreso XP acumulado
  Widget _buildLevelProgressCard(
    BuildContext context, {
    required GamificationPointsSummary pointsSummary,
    VoidCallback? onMostrarReglas,
  }) {
    final tier = pointsSummary.tier;
    final currentXp = pointsSummary.xpInTier;
    final targetXp = pointsSummary.targetXpInTier;
    final level = tier.level;
    final progress = pointsSummary.progressInTier;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tier.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nivel $level',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: tier.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tier.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              Text(
                level < 6 ? '$currentXp / $targetXp XP' : '${pointsSummary.totalPoints} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: AppColors.borderOf(context),
              valueColor: AlwaysStoppedAnimation<Color>(tier.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level < 6
                    ? 'Faltan ${pointsSummary.xpRemaining} XP para ascender al Nivel ${level + 1}'
                    : '¡Rango de honor máximo alcanzado!',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMutedOf(context),
                ),
              ),
              InkWell(
                onTap: onMostrarReglas,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.help_outline_rounded, size: 13, color: tier.primaryColor),
                      const SizedBox(width: 3),
                      Text(
                        'Reglas y XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Selector de categorías filtrables
  Widget _buildCategorySelector(BuildContext context) {
    final categories = [
      {'key': 'all', 'label': 'Todos'},
      {'key': 'moodle', 'label': 'Moodle LMS'},
      {'key': 'tutor', 'label': 'Tutor IA'},
      {'key': 'habits', 'label': 'Hábitos'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(
                cat['label']!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
                ),
              ),
              selectedColor: AppColors.brandOf(context),
              backgroundColor: AppColors.surfaceOf(context),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.borderOf(context),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat['key']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Tarjeta de cada logro con indicador de progreso y estado
  Widget _buildAchievementCard(BuildContext context, AchievementItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con insignia
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.isUnlocked
                  ? AppColors.brandOf(context).withValues(alpha: 0.10)
                  : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.isUnlocked
                  ? (item.id == 'racha_academica' ? const Color(0xFFD97706) : AppColors.brandOf(context))
                  : AppColors.textMutedOf(context),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Contenido descriptivo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ),
                    if (item.isUnlocked)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded, size: 11, color: Color(0xFF059669)),
                                SizedBox(width: 3),
                                Text(
                                  'Completado',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF059669),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${item.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.brandOf(context).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${item.xpReward} XP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandOf(context),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Barra de progreso del logro
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: item.percent,
                          minHeight: 6,
                          backgroundColor: AppColors.borderOf(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.isUnlocked ? const Color(0xFF059669) : AppColors.brandOf(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item.currentProgress}/${item.maxProgress}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMutedOf(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal interactivo y estructurado con las reglas de juego, niveles y recompensas XP.
class _ReglasGamificacionModal extends StatelessWidget {
  const _ReglasGamificacionModal();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = AppColors.brandOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tirador superior (drag handle)
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Cabecera del modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reglas y Recompensas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryOf(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Puntos Rumbo (XP), Niveles y Logros',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),

          // Contenido con scroll
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ¿Cómo sumar Puntos Rumbo?
                  _buildSectionTitle(context, '1. ¿Cómo sumar Puntos Rumbo (XP)?'),
                  const SizedBox(height: 10),
                  _buildRuleCard(
                    context,
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFF2563EB),
                    title: 'Entregas a tiempo en Moodle',
                    reward: '+50 XP',
                    description: 'Por cada tarea programada en Moodle que envíes antes de su fecha límite.',
                  ),
                  const SizedBox(height: 8),
                  _buildRuleCard(
                    context,
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF059669),
                    title: 'Cursos en Zona Segura',
                    reward: '+100 XP',
                    description: 'Por cada curso donde el modelo predictivo de IA determine riesgo BAJO.',
                  ),
                  const SizedBox(height: 8),
                  _buildRuleCard(
                    context,
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFD97706),
                    title: 'Medallas del Salón',
                    reward: '+80 a +150 XP',
                    description: 'Gana la recompensa indicada al desbloquear cada uno de los 6 logros académicos.',
                  ),

                  const SizedBox(height: 22),

                  // 2. Niveles de Maestría
                  _buildSectionTitle(context, '2. Niveles de Maestría y Rangos (Ciclo de 14 semanas)'),
                  const SizedBox(height: 6),
                  Text(
                    'Tus Puntos Rumbo (XP) se acumulan durante todo el semestre y desbloquean marcos y prestigios cosméticos en tu perfil:',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondaryOf(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 1',
                    rango: 'Explorador Inicial',
                    xpRange: '0 - 399 XP',
                    badgeColor: const Color(0xFF64748B),
                    desc: 'Semanas 1-3: Primeras metas del ciclo, organización y hábitos iniciales.',
                  ),
                  const SizedBox(height: 8),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 2',
                    rango: 'Estudiante Constante',
                    xpRange: '400 - 899 XP',
                    badgeColor: const Color(0xFF2563EB),
                    desc: 'Semanas 4-6: Entregas al día, constancia de ingresos y hábitos regulares.',
                  ),
                  const SizedBox(height: 8),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 3',
                    rango: 'Estratega Académico',
                    xpRange: '900 - 1,499 XP',
                    badgeColor: const Color(0xFF7C3AED),
                    desc: 'Semanas 7-9: Cursos en zona segura, notas aprobatorias y diagnósticos activos.',
                  ),
                  const SizedBox(height: 8),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 4',
                    rango: 'Mentor Destacado',
                    xpRange: '1,500 - 2,199 XP',
                    badgeColor: const Color(0xFFD97706),
                    desc: 'Semanas 10-12: Alto rendimiento sostenido y consolidación del ciclo.',
                  ),
                  const SizedBox(height: 8),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 5',
                    rango: 'Maestro del Ciclo',
                    xpRange: '2,200 - 2,999 XP',
                    badgeColor: const Color(0xFF0284C7),
                    desc: 'Semanas 13-14: Recta final con todas las metas y competencias conquistadas.',
                  ),
                  const SizedBox(height: 8),
                  _buildLevelRow(
                    context,
                    nivel: 'Nivel 6+',
                    rango: 'Leyenda de San Marcos',
                    xpRange: '3,000+ XP',
                    badgeColor: const Color(0xFFD97706),
                    desc: 'Máxima autorregulación y excelencia honorífica acumulada en el semestre.',
                  ),

                  const SizedBox(height: 22),

                  // 3. Frecuencia y renovación de metas
                  _buildSectionTitle(context, '3. ¿Cuándo se actualizan las metas y el XP?'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: brand.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: brand.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.autorenew_rounded, size: 18, color: brand),
                            const SizedBox(width: 8),
                            Text(
                              'Metas Semanales vs. Ciclo Universitario',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryOf(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Los Puntos Rumbo (XP) NUNCA se pierden: Aunque las metas semanales (Constancia y Estratega) se renueven cada lunes para que puedas volver a sumar puntos, todo el XP acumulado permanece intacto a lo largo de las 14 semanas del ciclo.\n\n'
                          '• Recompensas Cosméticas: Al subir de nivel desbloqueas marcos evolutivos para tu avatar (Pizarra, Zafiro, Amatista, Oro, Diamante y Corona Imperial) visibles en tu perfil y menú lateral.\n\n'
                          '• Constancia Semanal: Cada lunes arranca una nueva semana para motivarte a mantener el hábito de 4 días de conexión (+80 XP).\n\n'
                          '• Estratega del Aprendizaje: Se renueva cada lunes. Revisa «¿Por qué este resultado?» en cada curso para asegurar tus +90 XP semanales.\n\n'
                          '• Cuestionarios, Tutor y Tareas: Suman permanentemente a tu maestría del ciclo.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '¡Entendido, a sumar XP!',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryOf(context),
      ),
    );
  }

  Widget _buildRuleCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String reward,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reward,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryOf(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(
    BuildContext context, {
    required String nivel,
    required String rango,
    required String xpRange,
    required Color badgeColor,
    required String desc,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      nivel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rango,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              Text(
                xpRange,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMutedOf(context),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
