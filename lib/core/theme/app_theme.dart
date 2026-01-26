import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme für Publy
/// 
/// Enthält das Light Theme mit allen Brand-Farben und UI-Komponenten-Styles
class AppTheme {
  AppTheme._();

  /// Light Theme für die App
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      dividerTheme: _dividerTheme,
      textTheme: _textTheme,
    );
  }

  /// ColorScheme mit allen Brand-Farben
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.sageGreen,
    onPrimary: AppColors.white,
    secondary: AppColors.terracotta,
    onSecondary: AppColors.white,
    surface: AppColors.cream,
    onSurface: AppColors.deepCharcoal,
    error: AppColors.terracotta,
    onError: AppColors.white,
    outline: AppColors.subtleGrey,
  );

  /// AppBar Theme
  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.cream,
    foregroundColor: AppColors.deepCharcoal,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColors.deepCharcoal,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Card Theme
  static const CardThemeData _cardTheme = CardThemeData(
    color: AppColors.cream,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  /// Input Decoration Theme (für TextFields)
  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cream,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.subtleGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.subtleGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.terracotta),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.deepCharcoal),
    hintStyle: TextStyle(
      color: AppColors.deepCharcoal.withValues(alpha: 0.6),
    ),
  );

  /// Elevated Button Theme
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.sageGreen,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// Text Button Theme
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.sageGreen,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// Outlined Button Theme
  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.sageGreen,
      side: const BorderSide(color: AppColors.sageGreen),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// Floating Action Button Theme
  static const FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.terracotta,
    foregroundColor: AppColors.white,
    elevation: 2,
  );

  /// Divider Theme
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.subtleGrey,
    thickness: 1,
    space: 1,
  );

  /// Text Theme
  /// 
  /// Headlines verwenden Fredoka (Rounded & Friendly)
  /// UI/Body verwendet Inter (Clean & Professional)
  static final TextTheme _textTheme = TextTheme(
    // Display Large: Splash Screen Name, Hero Titel
    displayLarge: GoogleFonts.fredoka(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: AppColors.deepCharcoal,
    ),
    // Headline Large: Hauptüberschriften wie "Join the Pack"
    headlineLarge: GoogleFonts.fredoka(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.deepCharcoal,
    ),
    // Headline Medium: Dashboard-Begrüßung, Kartentitel
    headlineMedium: GoogleFonts.fredoka(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.deepCharcoal,
    ),
    // Title Medium: Button-Texte (weiß auf Salbeigrün), Tab-Bar Labels
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    // Body Large: Eingabefelder (Placeholder), Haupt-Fließtext
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.deepCharcoal,
    ),
    // Body Medium: Unterüberschriften, Info-Texte
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.deepCharcoal,
    ),
    // Label Small: Validierungshinweise, kleine Badges
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.deepCharcoal.withValues(alpha: 0.7),
    ),
  );
}
