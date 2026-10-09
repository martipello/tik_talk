import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'dial_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(DialTheme dialTheme) => FlexThemeData.light(
        colors: FlexSchemeColor.from(primary: dialTheme.accentColor),
        useMaterial3: true,
      );

  static ThemeData dark(DialTheme dialTheme) => FlexThemeData.dark(
        colors: FlexSchemeColor.from(primary: dialTheme.accentColor),
        useMaterial3: true,
      );
}
