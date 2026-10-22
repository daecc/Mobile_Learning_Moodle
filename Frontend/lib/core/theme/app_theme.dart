import 'package:flutter/material.dart';

/// Paleta oficial del sistema de diseño "Rumbo" (Mobile Learning UNMSM).
class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF1E3A8A); // Deep Navy oficial
  static const Color brandDark = Color(0xFF0F172A); // Slate 900
  static const Color brandSoft = Color(0xFFEFF6FF); // Slate/Blue 50

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Estados semánticos limpios y funcionales
  static const Color riskLow = Color(0xFF059669); // Emerald 600
  static const Color riskLowSoft = Color(0xFFD1FAE5); // Mint 100 suave
  static const Color riskLowText = Color(0xFF065F46); // Emerald 800

  static const Color riskMedium = Color(0xFFD97706); // Amber 600
  static const Color riskMediumSoft = Color(0xFFFEF3C7); // Amber 100
  static const Color riskMediumText = Color(0xFF92400E);

  static const Color riskHigh = Color(0xFFE11D48); // Rose 600
  static const Color riskHighSoft = Color(0xFFFEE2E2); // Rose 100
  static const Color riskHighText = Color(0xFF991B1B);

  static const Color neutral = Color(0xFF64748B); // Slate 500
  static const Color neutralSoft = Color(0xFFE2E8F0); // Slate 200

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC); // Slate 50 limpio
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Paleta Dark Mode (Obsidian / Slate profundo)
  static const Color surfaceDark = Color(0xFF151C28);
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color borderDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color brandSoftDark = Color(0xFF1E293B);

  /// Sombra suave y moderna para tarjetas en modo claro
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  /// Sombra dinámica dependiente del tema
  static List<BoxShadow> cardShadowOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : cardShadow;
  }

  // Helpers contextuales para modo oscuro / claro
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surface;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : background;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : border;

  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMuted;

  static Color brandSoftOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? brandSoftDark : brandSoft;

  static Color brandOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF60A5FA) : brand;

  /// Devuelve el color principal asociado a un nivel de riesgo.
  static Color forLevel(String nivelRiesgo) {
    switch (nivelRiesgo.toUpperCase()) {
      case 'BAJO':
        return riskLow;
      case 'MODERADO':
        return riskMedium;
      case 'CRITICO':
        return riskHigh;
      default:
        return neutral;
    }
  }

  /// Devuelve el color de fondo suave asociado a un nivel de riesgo.
  static Color softForLevel(String nivelRiesgo) {
    switch (nivelRiesgo.toUpperCase()) {
      case 'BAJO':
        return riskLowSoft;
      case 'MODERADO':
        return riskMediumSoft;
      case 'CRITICO':
        return riskHighSoft;
      default:
        return neutralSoft;
    }
  }

  /// Etiqueta legible para mostrar en la interfaz.
  static String labelForLevel(String nivelRiesgo) {
    switch (nivelRiesgo.toUpperCase()) {
      case 'BAJO':
        return 'Seguro';
      case 'MODERADO':
        return 'En riesgo';
      case 'CRITICO':
        return 'Riesgo crítico';
      case 'SIN_ESTIMACION':
        return 'Sin estimación';
      default:
        return 'Sin estimación';
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.brand, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        surface: AppColors.surfaceDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.brand, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
