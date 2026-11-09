import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  // Matches AppShell's rail breakpoint - pages use this to decide whether to
  // suppress their own AppBar, since the NavigationRail already carries the
  // destination context a title bar would otherwise repeat.
  static const double railWidth = 600;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= railWidth;
}
