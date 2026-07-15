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

  /// Texto secundario (subtítulos, fechas, metadatos en listas): mismo tono
  /// que [ink] pero más suave, para distinguirlo del título principal.
  static const Color mutedInk = Color(0xFF74695C);

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
      displayLarge: displayFont.displayLarge?.copyWith(fontSize: 44, color: ink),
      displayMedium: displayFont.displayMedium?.copyWith(fontSize: 36, color: ink),
      displaySmall: displayFont.displaySmall?.copyWith(fontSize: 30, color: ink),
      headlineLarge: displayFont.headlineLarge?.copyWith(fontSize: 30, color: ink),
      headlineMedium: displayFont.headlineMedium?.copyWith(fontSize: 27, color: ink),
      headlineSmall: displayFont.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: displayFont.titleLarge?.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: displayFont.titleMedium?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleSmall: displayFont.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(fontSize: 17, color: ink),
      bodyMedium: bodyFont.bodyMedium?.copyWith(fontSize: 15, color: ink),
      bodySmall: bodyFont.bodySmall?.copyWith(fontSize: 13.5, color: mutedInk),
      labelLarge: bodyFont.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: ink),
      labelMedium: bodyFont.labelMedium?.copyWith(fontSize: 13, color: mutedInk),
      labelSmall: bodyFont.labelSmall?.copyWith(fontSize: 12, color: mutedInk),
    );

    const thinBorder = BorderSide(color: hairline, width: 1);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: displayFont.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
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
      // Acción principal: también con borde fino y sin relleno, coherente
      // con el resto de la UI ("bordes finos sin relleno").
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: hairline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => bodyFont.labelMedium?.copyWith(
            fontSize: 12.5,
            color: states.contains(WidgetState.selected) ? ink : mutedInk,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
