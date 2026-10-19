import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

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

  // Lista de logros académicos alineados con las estrategias del modelo
  final List<AchievementItem> _allAchievements = const [
    AchievementItem(
      id: 'entrega_impecable',
      title: 'Entrega Impecable',
      description: 'Envía 5 tareas en Moodle antes de la fecha límite sin prórroga.',
      category: 'moodle',
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF10B981),
      currentProgress: 5,
      maxProgress: 5,
      xpReward: 100,
      isUnlocked: true,
      dateUnlocked: 'Ayer',
    ),
    AchievementItem(
      id: 'zona_segura',
      title: 'Guardián del Rendimiento',
      description: 'Mantén todos tus cursos matriculados en nivel de riesgo Bajo.',
      category: 'habits',
      icon: Icons.shield_rounded,
      iconColor: Color(0xFF3B82F6),
      currentProgress: 3,
      maxProgress: 4,
      xpReward: 150,
      isUnlocked: false,
    ),
    AchievementItem(
      id: 'curioso_digital',
      title: 'Mente Inquisitiva',
      description: 'Realiza 10 consultas reflexivas con el Tutor Inteligente IA.',
      category: 'tutor',
      icon: Icons.psychology_rounded,
      iconColor: Color(0xFF8B5CF6),
      currentProgress: 8,
      maxProgress: 10,
      xpReward: 120,
      isUnlocked: false,
    ),
    AchievementItem(
      id: 'racha_academica',
      title: 'Racha de Campeón',
      description: 'Ingresa a revisar tus materiales durante 7 días consecutivos.',
      category: 'habits',
      icon: Icons.local_fire_department_rounded,
      iconColor: Color(0xFFF59E0B),
      currentProgress: 5,
      maxProgress: 7,
      xpReward: 80,
      isUnlocked: false,
    ),
    AchievementItem(
      id: 'maestro_quiz',
      title: 'As de los Cuestionarios',
      description: 'Obtén calificación sobresaliente en 3 evaluaciones continuas.',
      category: 'moodle',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFEC4899),
      currentProgress: 3,
      maxProgress: 3,
      xpReward: 200,
      isUnlocked: true,
      dateUnlocked: '14 Oct',
    ),
    AchievementItem(
      id: 'feedback_activo',
      title: 'Estratega del Aprendizaje',
      description: 'Revisa tus diagnósticos metacognitivos de riesgo cada semana.',
      category: 'tutor',
      icon: Icons.insights_rounded,
      iconColor: Color(0xFF06B6D4),
      currentProgress: 2,
      maxProgress: 4,
      xpReward: 90,
      isUnlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final coursesVm = context.watch<CoursesViewModel>();
    final authStudent = context.watch<AuthViewModel>().student;

    final studentName = authStudent?.nombre ?? coursesVm.studentName;
    final totalCursos = coursesVm.courses.isNotEmpty ? coursesVm.courses.length : 4;
    final safeCourses = coursesVm.summary.bajo;

    final filteredAchievements = _selectedCategory == 'all'
        ? _allAchievements
        : _allAchievements.where((a) => a.category == _selectedCategory).toList();

    final unlockedCount = _allAchievements.where((a) => a.isUnlocked).length;
    final totalPoints = _allAchievements
        .where((a) => a.isUnlocked)
        .fold<int>(0, (acc, item) => acc + item.xpReward);

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
              totalPoints: totalPoints + 80, // Base points
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
                  rachaDias: 5,
                  medallasDesbloqueadas: '$unlockedCount/${_allAchievements.length}',
                  cursosSeguros: '$safeCourses/$totalCursos',
                ),
              ),
            ),

            // ==========================================
            // BARRA DE NIVEL Y PROGRESO XP
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: _buildLevelProgressCard(context, currentXp: 380, targetXp: 500, level: 4),
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
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '$unlockedCount Obtenidos',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.amber,
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
  }) {
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
                                'Estrategia 5 · Motivación & Retención',
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
                        'Rango: Estudiante Imparable',
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

  /// Slot preparado específicamente para renderizar tu animación Lottie de trofeo
  Widget _buildLottieSlot() {
    // Si tienes un archivo lottie listo (ej: 'assets/animations/trophy.json'),
    // solo descomentas Lottie.asset y comentas el placeholder visual.
    const String? lottieAssetPath = null; // Ej: 'assets/animations/trophy.json'

    if (lottieAssetPath != null) {
      return SizedBox(
        height: 120,
        width: 120,
        child: Lottie.asset(
          lottieAssetPath,
          fit: BoxFit.contain,
          repeat: true,
        ),
      );
    }

    // Placeholder estilizado con degradado y halo dorado hasta que agregues tu JSON Lottie
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.35),
            Colors.amber.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD54F),
                Color(0xFFFFA000),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            size: 46,
            color: Colors.white,
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
            iconColor: const Color(0xFFF97316),
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
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFF59E0B),
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
            iconColor: const Color(0xFF10B981),
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
                      color: AppColors.brand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nivel $level',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand,
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
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
              selectedColor: AppColors.brand,
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
        border: Border.all(
          color: item.isUnlocked
              ? Colors.amber.withValues(alpha: isDark ? 0.35 : 0.4)
              : AppColors.borderOf(context),
          width: item.isUnlocked ? 1.5 : 1,
        ),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.isUnlocked
                  ? item.iconColor.withValues(alpha: 0.16)
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isUnlocked
                    ? item.iconColor.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              item.icon,
              color: item.isUnlocked ? item.iconColor : AppColors.textMutedOf(context),
              size: 26,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 12, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'LOGRADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '+${item.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand,
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
                            item.isUnlocked ? Colors.green : item.iconColor,
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
