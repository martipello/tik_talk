import 'package:flutter/material.dart';

const double kMaxScreenWidth = 960;

class ViewConstraint extends StatelessWidget {
  const ViewConstraint({super.key, required this.child, this.constraints, this.expand = true});

  final Widget child;
  final BoxConstraints? constraints;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final constrainedChild = Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      constraints: constraints ?? const BoxConstraints(maxWidth: kMaxScreenWidth),
      child: child,
    );
    return expand ? Center(child: constrainedChild) : constrainedChild;
  }
}
