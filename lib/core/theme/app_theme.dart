import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF2DD4BF),
            onPrimary: Color(0xFF04201E),
            secondary: Color(0xFF5EEAD4),
            surface: Color(0xFF121A2B),
            onSurface: Color(0xFFE6EAF0),
            onSurfaceVariant: Color(0xFF94A3B8),
            surfaceContainerHighest: Color(0xFF1A2438),
            outline: Color(0xFF475569),
            outlineVariant: Color(0xFF263145),
            error: Color(0xFFF87171),
          )
        : const ColorScheme.light(
            primary: Color(0xFF0F766E),
            onPrimary: Colors.white,
            secondary: Color(0xFF14B8A6),
            surface: Colors.white,
            onSurface: Color(0xFF0F172A),
            onSurfaceVariant: Color(0xFF64748B),
            surfaceContainerHighest: Color(0xFFF1F4F8),
            outline: Color(0xFF94A3B8),
            outlineVariant: Color(0xFFE3E8EF),
            error: Color(0xFFDC2626),
          );

    final base = ThemeData(brightness: brightness);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F7F9),
      textTheme: textTheme,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
