import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema "Classical": tipografía serif (Cormorant Garamond para títulos,
/// Lora para cuerpo), acento dorado, bordes finos sin relleno.
abstract final class AppTheme {
  static const Color accent = Color(0xFFB68235);
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2A2622);
  static const Color hairline = Color(0xFFD8CFC2);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        primary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
    );

    final displayFont = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);
    final bodyFont = GoogleFonts.loraTextTheme(base.textTheme);

    final textTheme = bodyFont.copyWith(
      displayLarge: displayFont.displayLarge,
      displayMedium: displayFont.displayMedium,
      displaySmall: displayFont.displaySmall,
      headlineLarge: displayFont.headlineLarge,
      headlineMedium: displayFont.headlineMedium,
      headlineSmall: displayFont.headlineSmall,
      titleLarge: displayFont.titleLarge,
      titleMedium: displayFont.titleMedium,
      titleSmall: displayFont.titleSmall,
    );

    const thinBorder = BorderSide(color: hairline, width: 1);

    return base.copyWith(
      textTheme: textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: displayFont.headlineSmall?.copyWith(color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: thinBorder,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        side: thinBorder,
        shape: const StadiumBorder(side: thinBorder),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderSide: thinBorder,
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: thinBorder,
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: thinBorder,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: hairline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
