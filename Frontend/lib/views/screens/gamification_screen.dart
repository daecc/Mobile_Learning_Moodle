import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/metacognitive_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/tutor_viewmodel.dart';

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
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final coursesVm = context.watch<CoursesViewModel>();
    final authStudent = context.watch<AuthViewModel>().student;
    final metacognitiveVm = context.watch<MetacognitiveViewModel>();
    final tutorVm = context.watch<TutorViewModel>();

    final studentName = authStudent?.nombre ?? coursesVm.studentName;
    final totalCursos = coursesVm.courses.isNotEmpty ? coursesVm.courses.length : 2;
    final safeCourses = coursesVm.courses.where((c) => c.nivelRiesgo == 'BAJO').length;

    // Métricas reales extraídas en vivo
    final tareasTotales = metacognitiveVm.tareasTotales > 0 ? metacognitiveVm.tareasTotales : 5;
    final tareasEntregadas = metacognitiveVm.tareasEntregadas;
    final diasActivos = metacognitiveVm.accesosSemanales.isNotEmpty
        ? metacognitiveVm.accesosSemanales.last.toInt()
        : 1;
    final tutorConsultas = tutorVm.mensajes.where((m) => m.esUsuario).length;

    // Lista de logros académicos conectados a la realidad del estudiante
    final allAchievements = [
      AchievementItem(
        id: 'entrega_impecable',
        title: 'Entrega Impecable',
        description: 'Envía todas tus tareas en Moodle antes de la fecha límite ($tareasEntregadas de $tareasTotales entregadas).',
        category: 'moodle',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: tareasEntregadas,
        maxProgress: tareasTotales,
        xpReward: 100,
        isUnlocked: tareasEntregadas >= tareasTotales,
        dateUnlocked: tareasEntregadas >= tareasTotales ? 'Completado' : null,
      ),
      AchievementItem(
        id: 'zona_segura',
        title: 'Guardián del Rendimiento',
        description: 'Mantén todos tus cursos matriculados en nivel de riesgo Bajo ($safeCourses de $totalCursos seguros).',
        category: 'habits',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: safeCourses,
        maxProgress: totalCursos,
        xpReward: 150,
        isUnlocked: safeCourses >= totalCursos && totalCursos > 0,
        dateUnlocked: (safeCourses >= totalCursos && totalCursos > 0) ? 'Activo' : null,
      ),
      AchievementItem(
        id: 'maestro_quiz',
        title: 'As de los Cuestionarios',
        description: 'Obtén calificación aprobatoria sólida en tus evaluaciones continuas.',
        category: 'moodle',
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFFD97706),
        currentProgress: coursesVm.courses.any((c) => c.porcentajeRiesgo <= 30) ? 1 : 0,
        maxProgress: 1,
        xpReward: 120,
        isUnlocked: coursesVm.courses.any((c) => c.porcentajeRiesgo <= 30),
        dateUnlocked: 'Ciclo actual',
      ),
      AchievementItem(
        id: 'racha_academica',
        title: 'Constancia Semanal',
        description: 'Cumple la meta recomendada de 4 días de actividad semanal en el aula virtual.',
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
        description: 'Revisa tus diagnósticos metacognitivos de riesgo cada semana.',
        category: 'tutor',
        icon: Icons.insights_rounded,
        iconColor: const Color(0xFF2563EB),
        currentProgress: coursesVm.courses.isNotEmpty ? 1 : 0,
        maxProgress: 1,
        xpReward: 90,
        isUnlocked: coursesVm.courses.isNotEmpty,
        dateUnlocked: coursesVm.courses.isNotEmpty ? 'Esta semana' : null,
      ),
      AchievementItem(
        id: 'curioso_digital',
        title: 'Mente Inquisitiva',
        description: 'Realiza consultas reflexivas con el Tutor Inteligente IA.',
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
    final totalPoints = (tareasEntregadas * 50) +
        (safeCourses * 100) +
        allAchievements.where((a) => a.isUnlocked).fold<int>(0, (acc, item) => acc + item.xpReward);

    final level = (totalPoints ~/ 200) + 1;
    final currentXpInLevel = totalPoints % 200;
    const targetXpInLevel = 200;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SingleChildScrollView(
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
              level: level,
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
                currentXp: currentXpInLevel,
                targetXp: targetXpInLevel,
                level: level,
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
    );
  }

  /// Header superior curvo azul con diseño similar a Mis Cursos
  Widget _buildHeroHeader({
    required BuildContext context,
    required ThemeViewModel themeVm,
    required String studentName,
    required int totalPoints,
    required int level,
  }) {
    final String rangoTexto;
    if (level <= 1) {
      rangoTexto = 'Rango: Explorador Inicial';
    } else if (level == 2) {
      rangoTexto = 'Rango: Estudiante Constante';
    } else if (level == 3) {
      rangoTexto = 'Rango: Estratega Académico';
    } else {
      rangoTexto = 'Rango: Estudiante Imparable';
    }
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        rangoTexto,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade200,
                          letterSpacing: 0.3,
                        ),
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
    required int currentXp,
    required int targetXp,
    required int level,
  }) {
    final progress = (currentXp / targetXp).clamp(0.0, 1.0);

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
                      color: AppColors.brandOf(context).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nivel $level',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progreso de Maestría',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXp / $targetXp XP',
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandOf(context)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Faltan ${targetXp - currentXp} XP para ascender al Nivel ${level + 1}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMutedOf(context),
            ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      )
                    else
                      Text(
                        '+${item.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandOf(context),
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
