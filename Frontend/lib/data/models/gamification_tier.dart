import 'package:flutter/material.dart';

/// Modelo de Rango y Nivel de Gamificación adaptado a un ciclo universitario (14-16 semanas).
class GamificationTier {
  final int level;
  final String title;
  final String subtitle;
  final int minXp;
  final int maxXp;
  final List<Color> borderGradient;
  final Color primaryColor;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData icon;

  const GamificationTier({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.minXp,
    required this.maxXp,
    required this.borderGradient,
    required this.primaryColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.icon,
  });

  /// Lista oficial de los 6 rangos adaptados a las 14 semanas del ciclo
  static const List<GamificationTier> allTiers = [
    GamificationTier(
      level: 1,
      title: 'Explorador Inicial',
      subtitle: 'Semanas 1-3 · Primeras metas y organización de ciclo',
      minXp: 0,
      maxXp: 399,
      borderGradient: [Color(0xFF94A3B8), Color(0xFF64748B)],
      primaryColor: Color(0xFF64748B),
      badgeBgColor: Color(0xFFF1F5F9),
      badgeTextColor: Color(0xFF475569),
      icon: Icons.explore_rounded,
    ),
    GamificationTier(
      level: 2,
      title: 'Estudiante Constante',
      subtitle: 'Semanas 4-6 · Entregas al día y hábitos de conexión',
      minXp: 400,
      maxXp: 899,
      borderGradient: [Color(0xFF60A5FA), Color(0xFF2563EB)],
      primaryColor: Color(0xFF2563EB),
      badgeBgColor: Color(0xFFEFF6FF),
      badgeTextColor: Color(0xFF1D4ED8),
      icon: Icons.local_fire_department_rounded,
    ),
    GamificationTier(
      level: 3,
      title: 'Estratega Académico',
      subtitle: 'Semanas 7-9 · Mitad de ciclo y diagnósticos activos',
      minXp: 900,
      maxXp: 1499,
      borderGradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      primaryColor: Color(0xFF7C3AED),
      badgeBgColor: Color(0xFFF5F3FF),
      badgeTextColor: Color(0xFF6D28D9),
      icon: Icons.psychology_rounded,
    ),
    GamificationTier(
      level: 4,
      title: 'Mentor Destacado',
      subtitle: 'Semanas 10-12 · Alto rendimiento y cursos seguros',
      minXp: 1500,
      maxXp: 2199,
      borderGradient: [Color(0xFFFBBF24), Color(0xFFD97706)],
      primaryColor: Color(0xFFD97706),
      badgeBgColor: Color(0xFFFEF3C7),
      badgeTextColor: Color(0xFFB45309),
      icon: Icons.shield_rounded,
    ),
    GamificationTier(
      level: 5,
      title: 'Maestro del Ciclo',
      subtitle: 'Semanas 13-14 · Recta final y excelencia académica',
      minXp: 2200,
      maxXp: 2999,
      borderGradient: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF6366F1)],
      primaryColor: Color(0xFF0284C7),
      badgeBgColor: Color(0xFFE0F2FE),
      badgeTextColor: Color(0xFF0369A1),
      icon: Icons.workspace_premium_rounded,
    ),
    GamificationTier(
      level: 6,
      title: 'Leyenda de San Marcos',
      subtitle: 'Semana 14+ · Máxima maestría y honor académico',
      minXp: 3000,
      maxXp: 3000,
      borderGradient: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
      primaryColor: Color(0xFFD97706),
      badgeBgColor: Color(0xFFFFFBEB),
      badgeTextColor: Color(0xFF92400E),
      icon: Icons.military_tech_rounded,
    ),
  ];

  /// Obtiene el tier correspondiente según los puntos de experiencia acumulados
  static GamificationTier fromXp(int xp) {
    if (xp >= 3000) return allTiers.last;
    for (final tier in allTiers) {
      if (xp >= tier.minXp && xp <= tier.maxXp) {
        return tier;
      }
    }
    return allTiers.first;
  }

  /// Puntos necesarios para completar este nivel
  int get spanXp {
    if (level >= 6) return 500;
    return (maxXp - minXp) + 1;
  }

  /// Puntos acumulados dentro del nivel actual
  int currentXpInTier(int totalXp) {
    if (totalXp <= minXp) return 0;
    if (level >= 6) return (totalXp - minXp).clamp(0, spanXp);
    return (totalXp - minXp).clamp(0, spanXp);
  }

  /// Progreso de 0.0 a 1.0 dentro del nivel actual
  double progress(int totalXp) {
    if (totalXp <= minXp) return 0.0;
    if (level >= 6) return 1.0;
    final current = totalXp - minXp;
    return (current / spanXp).clamp(0.0, 1.0);
  }

  /// Puntos que faltan para ascender al siguiente nivel
  int xpRemainingForNext(int totalXp) {
    if (level >= 6) return 0;
    final remaining = (maxXp - totalXp) + 1;
    return remaining > 0 ? remaining : 0;
  }
}

/// Resumen consolidado del cálculo de Gamificación y Puntos Rumbo
class GamificationPointsSummary {
  final int totalPoints;
  final GamificationTier tier;
  final int xpInTier;
  final int targetXpInTier;
  final double progressInTier;
  final int xpRemaining;

  const GamificationPointsSummary({
    required this.totalPoints,
    required this.tier,
    required this.xpInTier,
    required this.targetXpInTier,
    required this.progressInTier,
    required this.xpRemaining,
  });

  /// Calcula los puntos de experiencia acumulados sin perder el historial semanal
  static GamificationPointsSummary calculate({
    required int tareasEntregadas,
    required int safeCourses,
    required int totalCursos,
    required int tareasTotales,
    required bool tieneBuenPromedio,
    required int diasActivosSemanales,
    required bool esEstrategaEstaSemana,
    int semanasPreviasEstratega = 0,
    int semanasPreviasConstancia = 0,
    int tutorConsultas = 0,
  }) {
    int points = 0;

    // 1. Tareas entregadas a lo largo de las 14 semanas (50 XP c/u)
    points += tareasEntregadas * 50;

    // 2. Cursos en riesgo BAJO (100 XP c/u)
    points += safeCourses * 100;

    // 3. Logros del Ciclo (permanecen activos)
    if (tareasTotales == 0 || tareasEntregadas >= tareasTotales) {
      points += 100; // Entrega Impecable
    }
    if (totalCursos > 0 && safeCourses >= totalCursos) {
      points += 150; // Guardián del Rendimiento
    }
    if (tieneBuenPromedio) {
      points += 120; // As de los Cuestionarios
    }
    if (tutorConsultas >= 3) {
      points += 100; // Mente Inquisitiva
    }

    // 4. Metas Semanales (semana actual + semanas pasadas conservadas)
    if (diasActivosSemanales >= 4) {
      points += 80; // Constancia Semanal (esta semana)
    }
    points += semanasPreviasConstancia * 80;

    if (esEstrategaEstaSemana) {
      points += 90; // Estratega del Aprendizaje (esta semana)
    }
    points += semanasPreviasEstratega * 90;

    final tier = GamificationTier.fromXp(points);
    final xpInTier = tier.currentXpInTier(points);
    final targetXp = tier.spanXp;
    final progress = tier.progress(points);
    final xpRemaining = tier.xpRemainingForNext(points);

    return GamificationPointsSummary(
      totalPoints: points,
      tier: tier,
      xpInTier: xpInTier,
      targetXpInTier: targetXp,
      progressInTier: progress,
      xpRemaining: xpRemaining,
    );
  }
}
