import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // keyColors makes FlexColorScheme seed-generate the full tonal palette from
  // accentColor (like ColorScheme.fromSeed), instead of using it verbatim as
  // `primary` in both light/dark mode. That's required because accentColor is
  // user-chosen and can be pure black/white: used verbatim, `primary` stays
  // the same color in dark mode too, making primary-colored widgets (e.g.
  // OutlinedButton's border/text) invisible against a similarly dark surface.
  // Seed generation picks a tone of accentColor with guaranteed contrast for
  // the current brightness instead.
  static ThemeData light(Color accentColor) => FlexThemeData.light(
        colors: FlexSchemeColor.from(primary: accentColor),
        keyColors: const FlexKeyColors(),
        useMaterial3: true,
      );

  static ThemeData dark(Color accentColor) => FlexThemeData.dark(
        colors: FlexSchemeColor.from(primary: accentColor),
        keyColors: const FlexKeyColors(),
        useMaterial3: true,
      );
}
