import 'package:flutter/material.dart';

/// Paleta de colores y tema global (Material Design 3)
/// Colores semánticos para consistencia en toda la app
class AppTheme {
  // Colores primarios (Azul académico/profesional)
  static const Color _primaryBase = Color(0xFF1976D2); // Material Blue 700
  static const Color _primaryLight = Color(0xFF42A5F5);
  static const Color _primaryDark = Color(0xFF0D47A1);

  // Colores de estado (Semáforo)
  static const Color _successBase = Color(0xFF388E3C); // Material Green 700
  static const Color _warningBase = Color(0xFFF9A825); // Material Amber 700
  static const Color _errorBase = Color(0xFFD32F2F);   // Material Red 800

  // Neutros
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _background = Color(0xFFF8F9FA);
  static const Color _onSurface = Color(0xFF1C1B1F);
  static const Color _onSurfaceVariant = Color(0xFF49454F);
  static const Color _outline = Color(0xFF79747E);
  static const Color _onPrimary = Color(0xFFFFFFFF);

  // Getters públicos (static const para uso en const contexts)
  static const Color primaryColor = _primaryBase;
  static const Color primaryLightColor = _primaryLight;
  static const Color primaryDarkColor = _primaryDark;
  static const Color successColor = _successBase;
  static const Color warningColor = _warningBase;
  static const Color errorColor = _errorBase;
  static const Color surfaceColor = _surface;
  static const Color backgroundColor = _background;
  static const Color onSurfaceColor = _onSurface;
  static const Color onSurfaceVariantColor = _onSurfaceVariant;
  static const Color outlineColor = _outline;
  static const Color onPrimaryColor = _onPrimary;

  /// Tema claro (Light Theme) - Material 3
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBase,
      brightness: Brightness.light,
      primary: _primaryBase,
      secondary: _primaryLight,
      tertiary: _successBase,
      error: _errorBase,
      surface: _surface,
      background: _background,
      onSurface: _onSurface,
      onBackground: _onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      fontFamily: 'Roboto',

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: _onSurface),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        color: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _outline.withValues(alpha: 0.2)),
        ),
        margin: EdgeInsets.zero,
      ),

      // ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryBase,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // FilledButton theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryBase,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBase,
          side: BorderSide(color: _primaryBase, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBase,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryBase, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorBase),
        ),
        labelStyle: TextStyle(
          color: _onSurfaceVariant,
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          color: _onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
      ),

      // Text theme (Material 3)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          fontFamily: 'Roboto',
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          fontFamily: 'Roboto',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          fontFamily: 'Roboto',
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: _onSurfaceVariant,
        size: 24,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: _outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: _primaryBase.withValues(alpha: 0.1),
        selectedColor: _primaryBase.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: _primaryBase,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _primaryBase.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _onSurface.withValues(alpha: 0.9),
        contentTextStyle: TextStyle(
          color: _surface,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Tema oscuro (Dark Theme) - Material 3
  static ThemeData get darkTheme {
    const Color darkSurface = Color(0xFF1E1E1E);
    const Color darkBackground = Color(0xFF121212);
    const Color darkOnSurface = Color(0xFFE6E1E5);
    const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
    const Color darkOutline = Color(0xFF938F99);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryLight,
      brightness: Brightness.dark,
      primary: _primaryLight,
      secondary: _primaryBase,
      tertiary: _successBase,
      error: Color(0xFFEF5350),
      surface: darkSurface,
      background: darkBackground,
      onSurface: darkOnSurface,
      onBackground: darkOnSurface,
    );

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
      ),
      cardTheme: lightTheme.cardTheme?.copyWith(
        color: darkSurface,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      textTheme: lightTheme.textTheme.apply(
        bodyColor: darkOnSurface,
        displayColor: darkOnSurface,
      ),
      iconTheme: lightTheme.iconTheme?.copyWith(color: darkOnSurfaceVariant),
      dividerTheme: lightTheme.dividerTheme?.copyWith(
        color: darkOutline.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme?.copyWith(
        fillColor: darkSurface,
        labelStyle: TextStyle(color: darkOnSurfaceVariant),
        hintStyle: TextStyle(color: darkOnSurfaceVariant.withValues(alpha: 0.6)),
      ),
      snackBarTheme: lightTheme.snackBarTheme?.copyWith(
        backgroundColor: darkOnSurface.withValues(alpha: 0.9),
        contentTextStyle: TextStyle(color: darkBackground),
      ),
    );
  }
}