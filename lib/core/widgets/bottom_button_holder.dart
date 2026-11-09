import 'package:flutter/material.dart';

import 'view_constraint.dart';

class BottomButtonHolder extends StatelessWidget {
  const BottomButtonHolder({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ViewConstraint(child: child),
        ),
      ),
    );
  }
}
