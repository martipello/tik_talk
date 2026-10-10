import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(Color accentColor) => FlexThemeData.light(
        colors: FlexSchemeColor.from(primary: accentColor),
        useMaterial3: true,
      );

  static ThemeData dark(Color accentColor) => FlexThemeData.dark(
        colors: FlexSchemeColor.from(primary: accentColor),
        useMaterial3: true,
      );
}
