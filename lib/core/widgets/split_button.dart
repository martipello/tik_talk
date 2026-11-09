// Vendored from package:split_button 0.1.0 (MIT, Shoaib Hossain -
// https://github.com/mrsihab/flutter-split-button) rather than depended on
// directly, because of one layout bug: the action segment is a
// PopupMenuButton, which Flutter renders via an IconButton whose intrinsic
// height doesn't match the title segment's ElevatedButton, and the
// package's Row uses the default CrossAxisAlignment.center - so the two
// segments render at different heights, centered against each other,
// instead of lining up. No ButtonStyle/Theme override from outside this
// file can fix it, because the package sets fixedSize explicitly on both
// segments, and an explicit widget-level style always wins over an ambient
// theme. The only change from upstream is wrapping the Row in
// IntrinsicHeight with crossAxisAlignment: stretch, so both segments share
// the row's (intrinsic, tallest-child) height - crossAxisAlignment: stretch
// alone crashes here, because the outer SizedBox only constrains width, so
// the Row's own height is unbounded and it has nothing finite to stretch
// into; IntrinsicHeight measures the tallest child first and gives the Row
// a bounded height to stretch against.
//
// Second change from upstream: an optional `height`. When given, the outer
// SizedBox is tight on height too, which already bounds the Row, so
// crossAxisAlignment: stretch works without IntrinsicHeight - letting
// callers pin a SplitButton to the same fixed height as sibling buttons
// that aren't SplitButtons, instead of whatever its content wants.
//
// Third change from upstream: an explicit `constraints` on the
// PopupMenuButton, tight to `widget.width`. Each popup item's own Container
// (see _popupItemBuilder) is forced to that same width so it lines up with
// the title segment above it - but PopupMenuButton's menu defaults to
// capping its own Material (the surface the elevation shadow is actually
// attached to) at 280 logical pixels wide. Once `widget.width` exceeds
// that, the item's opaque Container overflows past the narrower Material -
// invisibly, since nothing clips it - so the shadow only wraps the part of
// the content that happens to still be under the capped Material and reads
// as "cut off" everywhere else. Matching the constraint to widget.width
// makes the Material (and its shadow) exactly as wide as the content again.
import 'package:flutter/material.dart';

class SplitButton<T> extends StatefulWidget {
  final Color? backgroundColor, foregroundColor;
  final VoidCallback? onPressed, onOpened, onCanceled;
  final Widget? leading, action;
  final Widget title;
  final Radius outerRadius, innerRadius, menuRadius;
  final bool enable;
  final double? elevation;
  final double width, spacing;
  final double? height;
  final List<SplitButtonEntry<T>> popupList;
  final ValueChanged<T>? onChanged;
  final Offset offset;

  const SplitButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.leading,
    this.action,
    this.outerRadius = const Radius.circular(30),
    this.innerRadius = const Radius.circular(7),
    this.menuRadius = const Radius.circular(20),
    this.elevation,
    this.enable = true,
    this.width = 200,
    this.spacing = 2,
    this.height,
    this.offset = const Offset(0, 0),
    this.onChanged,
    this.onOpened,
    this.onCanceled,
    required this.popupList,
    required this.title,
  });

  @override
  State<SplitButton<T>> createState() => _SplitButtonState<T>();
}

class SplitButtonEntry<T> {
  final T value;
  final Widget child;
  const SplitButtonEntry({required this.value, required this.child});
}

class _SplitButtonState<T> extends State<SplitButton<T>> {
  IconData icon = Icons.keyboard_arrow_down_rounded;
  void _onOpened() => setState(() => icon = Icons.keyboard_arrow_up_rounded);
  void _onClosed() => setState(() => icon = Icons.keyboard_arrow_down_rounded);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildSegments(),
    );

    if (widget.height != null) {
      return SizedBox(width: widget.width, height: widget.height, child: row);
    }
    return SizedBox(width: widget.width, child: IntrinsicHeight(child: row));
  }

  List<Widget> _buildSegments() {
    return [
      ElevatedButton.icon(
        onPressed: widget.onPressed ?? () {},
        icon: widget.leading,
        label: widget.title,
        style: ElevatedButton.styleFrom(
          elevation: widget.elevation,
          textStyle: TextStyle(overflow: TextOverflow.ellipsis),
          fixedSize: Size.fromWidth(widget.width - 55 - widget.spacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: widget.outerRadius,
              right: widget.innerRadius,
            ),
          ),
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
        ),
      ),
      SizedBox(width: widget.spacing),
      PopupMenuButton<T>(
        icon: widget.action ?? Icon(icon),
        padding: EdgeInsets.zero,
        elevation: widget.elevation,
        enabled: widget.enable,
        position: PopupMenuPosition.under,
        constraints: BoxConstraints.tightFor(width: widget.width),
        color: Colors.transparent,
        iconColor: widget.foregroundColor,
        offset: widget.offset,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          fixedSize: Size.fromWidth(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: widget.outerRadius,
              left: widget.innerRadius,
            ),
          ),
        ),
        itemBuilder: _popupItemBuilder,
        onOpened: () {
          if (widget.onOpened != null) {
            widget.onOpened!();
          }
          if (widget.action != null) {
            _onOpened();
          }
        },
        onCanceled: () {
          if (widget.onCanceled != null) {
            widget.onCanceled!();
          }
          if (widget.action != null) {
            _onClosed();
          }
        },
        onSelected: (value) {
          if (widget.onChanged != null) widget.onChanged!(value);
          _onClosed();
        },
      ),
    ];
  }

  List<PopupMenuEntry<T>> _popupItemBuilder(BuildContext context) {
    return widget.popupList
        .map(
          (entry) => PopupMenuItem<T>(
            value: entry.value,
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: widget.width,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: entry == widget.popupList.first
                        ? widget.menuRadius
                        : Radius.zero,
                    bottom: entry == widget.popupList.last
                        ? widget.menuRadius
                        : Radius.zero,
                  ),
                ),
                child: entry.child,
              ),
            ),
          ),
        )
        .toList();
  }
}
