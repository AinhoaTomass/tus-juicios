import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "Classical" (colores que no vienen ya cubiertos por
/// [ColorScheme]): fondo con textura cálida, tinta de texto y borde fino.
/// Se registra como [ThemeExtension] para que cambie sola entre [AppTheme.light]
/// y [AppTheme.dark] sin que cada widget tenga que saber qué tema hay activo.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.accentInk,
    required this.background,
    required this.surface,
    required this.ink,
    required this.hairline,
    required this.mutedInk,
  });

  final Color accent;

  /// Dorado para texto y rellenos (botones principales, etiquetas): más
  /// oscuro que [accent] en claro para llegar a contraste 4,5:1 sobre el
  /// fondo crema. [accent] queda para detalles decorativos (bordes, iconos).
  final Color accentInk;

  final Color background;
  final Color surface;
  final Color ink;
  final Color hairline;

  /// Texto secundario (subtítulos, fechas, metadatos en listas): mismo tono
  /// que [ink] pero más suave, para distinguirlo del título principal.
  final Color mutedInk;

  static const light = AppColors(
    accent: Color(0xFFB68235),
    accentInk: Color(0xFF8F6324),
    background: Color(0xFFFAF8F5),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2622),
    hairline: Color(0xFFD8CFC2),
    mutedInk: Color(0xFF74695C),
  );

  static const dark = AppColors(
    accent: Color(0xFFC99A4E),
    accentInk: Color(0xFFC99A4E),
    background: Color(0xFF1C1917),
    surface: Color(0xFF262220),
    ink: Color(0xFFEDE6DC),
    hairline: Color(0xFF463F37),
    mutedInk: Color(0xFFA89A88),
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? accentInk,
    Color? background,
    Color? surface,
    Color? ink,
    Color? hairline,
    Color? mutedInk,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      hairline: hairline ?? this.hairline,
      mutedInk: mutedInk ?? this.mutedInk,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t)!,
    );
  }
}

/// Tema "Classical": Cormorant Garamond (serif) para títulos de pantalla y
/// cabeceras; Inter (sans) para listas, datos, importes y formularios, con
/// cifras tabulares para que los números se alineen en columna. Acento
/// dorado y bordes finos. Con versión clara y oscura; los colores
/// concretos viven en [AppColors].
abstract final class AppTheme {
  /// Colores de la paleta activa (clara u oscura según el tema del sistema)
  /// para widgets que necesitan un color fuera de [ColorScheme].
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  static ThemeData get light => _build(AppColors.light);

  static ThemeData get dark => _build(AppColors.dark);

  static ThemeData _build(AppColors colors) {
    final brightness = colors == AppColors.dark ? Brightness.dark : Brightness.light;
    // Texto sobre relleno dorado: blanco en claro, tinta oscura en oscuro
    // (el dorado del tema oscuro es demasiado claro para texto blanco).
    final onAccent = brightness == Brightness.dark ? colors.background : Colors.white;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
        primary: colors.accentInk,
        onPrimary: onAccent,
        surface: colors.surface,
      ),
      scaffoldBackgroundColor: colors.background,
    );

    final displayFont = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);
    final bodyFont = GoogleFonts.interTextTheme(base.textTheme);
    const cifras = [FontFeature.tabularFigures()];

    final textTheme = bodyFont.copyWith(
      displayLarge: displayFont.displayLarge?.copyWith(fontSize: 44, color: colors.ink),
      displayMedium: displayFont.displayMedium?.copyWith(fontSize: 36, color: colors.ink),
      displaySmall: displayFont.displaySmall?.copyWith(fontSize: 30, color: colors.ink),
      headlineLarge: displayFont.headlineLarge?.copyWith(fontSize: 30, color: colors.ink),
      headlineMedium: displayFont.headlineMedium?.copyWith(fontSize: 27, color: colors.ink),
      headlineSmall: displayFont.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      titleLarge: displayFont.titleLarge?.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      // Nombres en tarjetas de listas y cabeceras de sección: en sans, que a
      // este tamaño se lee mejor que la serif fina en el móvil.
      titleMedium: bodyFont.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.ink,
        fontFeatures: cifras,
      ),
      titleSmall: bodyFont.titleSmall?.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: colors.ink,
        fontFeatures: cifras,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(fontSize: 16, color: colors.ink, fontFeatures: cifras),
      bodyMedium: bodyFont.bodyMedium?.copyWith(fontSize: 14.5, color: colors.ink, fontFeatures: cifras),
      bodySmall: bodyFont.bodySmall?.copyWith(fontSize: 13, color: colors.mutedInk, fontFeatures: cifras),
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(fontSize: 12.5, color: colors.mutedInk, fontFeatures: cifras),
      labelSmall: bodyFont.labelSmall?.copyWith(fontSize: 11.5, color: colors.mutedInk, fontFeatures: cifras),
    );

    final thinBorder = BorderSide(color: colors.hairline, width: 1);

    final primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: colors.accentInk,
      foregroundColor: onAccent,
      disabledBackgroundColor: colors.hairline,
      disabledForegroundColor: colors.mutedInk,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        elevation: 0,
        titleTextStyle: displayFont.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: thinBorder,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        side: thinBorder,
        shape: StadiumBorder(side: thinBorder),
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
          borderSide: BorderSide(color: colors.accent, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: thinBorder,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      // Acción principal (Guardar, Nuevo...): única pieza con relleno dorado,
      // para que se distinga a primera vista de las secundarias (borde fino).
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: primaryButtonStyle),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentInk,
        foregroundColor: onAccent,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        extendedTextStyle: bodyFont.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accent.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => bodyFont.labelMedium?.copyWith(
            fontSize: 12.5,
            color: states.contains(WidgetState.selected) ? colors.ink : colors.mutedInk,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
