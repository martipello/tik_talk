import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import '../../../core/models/lap.dart';
import '../../../core/theme/dial_face_style.dart';
import '../../../core/utils/lap_records.dart';
import '../../history/presentation/wear_history_screen.dart';
import '../../settings/presentation/wear_settings_screen.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';
import 'wear_laps_screen.dart';
import 'widgets/watch_face.dart';

// Matches the fastest/slowest colours LapBoard uses for a split, so the
// Laps button's badge reads the same way the phone's lap list already
// does - green/red isn't a new convention invented for the watch.
const _fastestColor = Color(0xFF34D97B);
const _slowestColor = Color(0xFFE5484D);

// Play/Pause/Lap/Stop are a plain centred row at the bottom - they're what's
// actually driving the timer, so they get their own fixed, never-moving
// spot rather than sharing room with navigation/utility icons.
const double _tier1Size = 50;
const double _tier1Icon = 24;
// Mute/Backlight: primary actions the phone also always keeps on-screen
// rather than tucked into Settings, one size down from the bottom row.
const double _tier2Size = 40;
const double _tier2Icon = 18;
// History/Settings: just navigation, smaller again.
const double _tier3Size = 30;
const double _tier3Icon = 14;

// Spacing between stacked icons in each side column - tightened twice now
// (8px originally, then 6px once a column held 3 icons, now 4px per
// explicit "closer together" feedback).
const double _iconGap = 4;
// Gap left between an icon and the round bezel - the margin every icon
// ends up at when it's at the screen's own vertical centre (the widest
// point), which is as close to a flat "edge margin" as a round screen has.
// Icons elsewhere in a column get pushed in further than this by the
// curve in _marginForY; this is just the floor, not a fixed inset.
const double _iconClearance = 8;

// A straight vertical column at a flat _edgeMargin turned out to not just
// need a bigger top offset (the previous fix) - doing the actual geometry
// for a column of 2-3 stacked icons shows there's no single topOffset that
// avoids clipping *somewhere* in the stack: the usable vertical band at a
// fixed horizontal inset is only tall enough, at this icon size/margin, for
// about one icon's worth of slack, not three. A column flush to one edge
// simply doesn't match a round screen's own shape.
//
// So each icon in a column gets its OWN inset instead of sharing one -
// computed from its actual height via the circle's equation, the same way
// the screen's own bezel curves in near the top/bottom and back out near
// the middle. _edgeMargin remains the inset at the widest point (the
// screen's vertical centre); icons away from that centre automatically
// get pushed inward exactly as far as curving with the bezel requires.
double _marginForY(double side, double iconSize, double yCenter) {
  final r = iconSize / 2;
  final screenRadius = side / 2;
  final dy = screenRadius - yCenter;
  final maxDx = screenRadius - _iconClearance - r;
  final dxSquared = maxDx * maxDx - dy * dy;
  final dx = dxSquared > 0 ? math.sqrt(dxSquared) : 0.0;
  return screenRadius - r - dx;
}

// Centring the whole stack on the screen's own vertical centre - not
// anchoring its top near the top edge - is what actually maximises how
// close to the top (and bottom) the end icons can get without clipping:
// the usable vertical band for a given inset is itself centred there, so
// starting anywhere else just wastes part of that band on one side.
List<Widget> _curvedIconColumn({
  required double side,
  required bool isLeft,
  required bool controlsVisible,
  required List<({double size, Widget child})> icons,
}) {
  final stackHeight =
      icons.fold<double>(0, (sum, icon) => sum + icon.size) + _iconGap * (icons.length - 1);
  var y = side / 2 - stackHeight / 2;

  final widgets = <Widget>[];
  for (final icon in icons) {
    final margin = _marginForY(side, icon.size, y + icon.size / 2);
    widgets.add(
      Positioned(
        top: y,
        left: isLeft ? margin : null,
        right: isLeft ? null : margin,
        child: _Fadable(visible: controlsVisible, child: icon.child),
      ),
    );
    y += icon.size + _iconGap;
  }
  return widgets;
}

// Shared fade behaviour for every piece of chrome that auto-hides while
// running - faded-out controls also stop accepting taps (IgnorePointer),
// so a tap anywhere they used to be falls through to the reveal layer
// underneath instead of silently triggering a button nobody can see.
class _Fadable extends StatelessWidget {
  const _Fadable({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: _WearTimerScreenState._fadeDuration,
        child: child,
      ),
    );
  }
}

class WearTimerScreen extends ConsumerStatefulWidget {
  const WearTimerScreen({super.key});

  @override
  ConsumerState<WearTimerScreen> createState() => _WearTimerScreenState();
}

class _WearTimerScreenState extends ConsumerState<WearTimerScreen> {
  // Backlight is ephemeral UI state, not a persisted setting - same as the
  // phone's _TimerPageState._isGlowing, not something read from providers.
  bool _isGlowing = false;

  void _toggleGlow() => setState(() => _isGlowing = !_isGlowing);

  // Only while actively running does the chrome fade away - idle/paused/
  // countingDown always need their own controls immediately reachable
  // (you're mid-interaction with them by definition), but a running
  // stopwatch is meant to be glanced at, not operated continuously, so
  // the buttons aren't worth permanently covering the dial for.
  static const _autoHideDelay = Duration(seconds: 4);
  static const _fadeDuration = Duration(milliseconds: 400);

  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    if (ref.read(timerNotifierProvider).status == TimerStatus.running) {
      _hideTimer = Timer(_autoHideDelay, () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  void _cancelAutoHide() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
  }

  void _openHistory() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WearHistoryScreen()));
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WearSettingsScreen()));
  }

  void _openLaps(List<Lap> laps, Color accentColor, DialFaceStyle dialFaceStyle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WearLapsScreen(laps: laps, accentColor: accentColor, dialFaceStyle: dialFaceStyle),
      ),
    );
  }

  // Same fastest/slowest-of-the-set logic LapBoard uses per row, applied
  // just to the most recently added lap - "changed for each one you add,"
  // so the badge keeps reflecting whatever was just recorded rather than
  // freezing on the first lap's result.
  Color _lapBadgeColor(List<Lap> laps, Color accentColor) {
    final records = buildLapRecords(laps);
    if (records.isEmpty) return accentColor;

    final splits = records.map((record) => record.split).toList();
    final fastestSplit = splits.reduce((a, b) => a < b ? a : b);
    final slowestSplit = splits.reduce((a, b) => a > b ? a : b);
    final hasVariation = fastestSplit != slowestSplit;
    final latest = records.last;

    if (hasVariation && latest.split == fastestSplit) return _fastestColor;
    if (hasVariation && latest.split == slowestSplit) return _slowestColor;
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    // Starting a run (idle/countingDown -> running) kicks off the first
    // auto-hide countdown; leaving it (pause/stop) always snaps the
    // controls back and cancels any pending hide - otherwise pausing while
    // faded would leave Resume/Reset invisible with nothing on screen left
    // to tap.
    ref.listen<TimerState>(timerNotifierProvider, (previous, next) {
      final enteredRunning = next.status == TimerStatus.running && previous?.status != TimerStatus.running;
      final leftRunning = previous?.status == TimerStatus.running && next.status != TimerStatus.running;
      if (enteredRunning) {
        _showControls();
      } else if (leftRunning) {
        _cancelAutoHide();
      }
    });

    final dialArea = LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;

        // The dial goes fully edge-to-edge now - no reserved strip for the
        // bottom Play/Pause/Lap/Stop row either, matching the side icon
        // columns (which already just sit on top of the dial artwork
        // rather than the dial shrinking to dodge them). Per explicit
        // sign-off, these controls overlapping the dial - or even running
        // a little past the visible edge - is fine as long as nothing
        // becomes unreachable, which opaque-background circular buttons
        // sitting on top of dial artwork never do.
        //
        // Dropped the 1.08 claw-back that used the dial's own margin slack
        // for extra size - at full edge-to-edge width that pushed the
        // dial past the screen's own bounding box, leaving zero padding at
        // all. A flat 0.96 instead gives it a small, deliberate margin.
        final dialSize = side * 0.96;

        final dial = SizedBox(
          width: dialSize,
          height: dialSize,
          child: WatchFace(
            timerState: timerState,
            dialFaceStyle: settings.dialFaceStyle,
            accentColor: settings.dialAccentColor.value,
            isGlowing: _isGlowing,
          ),
        );

        // Fluid Glass's orbs need an OCLiquidGlassGroup ancestor to refract
        // into or they fail to render - mirrors _TimerStage on the phone.
        // The phone also paints an animated FluidGlassBackground behind the
        // group for that refraction to play against - skipped here to keep
        // the watch layout cheap, so the orbs just refract the plain
        // background instead. Less dramatic, but not broken.
        final dialWithBackdrop = settings.dialFaceStyle.usesGlassBackdrop
            ? OCLiquidGlassGroup(
                settings: const OCLiquidGlassSettings(blurRadiusPx: 4),
                child: dial,
              )
            : dial;

        final leftIcons = [
          (
            size: _tier2Size,
            child: _WearIconButton(
              icon: settings.ttsMuted ? Icons.volume_off : Icons.volume_up,
              size: _tier2Size,
              iconSize: _tier2Icon,
              tooltip: settings.ttsMuted ? 'Unmute announcements' : 'Mute announcements',
              onPressed: () {
                ref.read(settingsNotifierProvider.notifier).updateTtsMuted(!settings.ttsMuted);
                _showControls();
              },
            ),
          ),
          (
            size: _tier2Size,
            child: _WearIconButton(
              icon: _isGlowing ? Icons.lightbulb : Icons.lightbulb_outline,
              size: _tier2Size,
              iconSize: _tier2Icon,
              tooltip: 'Backlight',
              onPressed: () {
                _toggleGlow();
                _showControls();
              },
            ),
          ),
        ];

        final rightIcons = [
          (
            size: _tier3Size,
            child: _WearIconButton(
              icon: Icons.history,
              size: _tier3Size,
              iconSize: _tier3Icon,
              tooltip: 'History',
              onPressed: () {
                _showControls();
                _openHistory();
              },
            ),
          ),
          (
            size: _tier3Size,
            // Badge instead of an inline list below the dial - that worked
            // on the phone/web's taller scrollable layout, but competed
            // with the dial/controls for the same small circle here. The
            // badge carries the same fastest/slowest colour coding the
            // phone's lap list already uses, just applied to the latest
            // lap instead of every row; tapping it opens the full list.
            child: Badge(
              isLabelVisible: timerState.laps.isNotEmpty,
              label: Text('${timerState.laps.length}'),
              backgroundColor: _lapBadgeColor(timerState.laps, settings.dialAccentColor.value),
              child: _WearIconButton(
                icon: Icons.flag,
                size: _tier3Size,
                iconSize: _tier3Icon,
                tooltip: 'Laps',
                onPressed: timerState.laps.isEmpty
                    ? null
                    : () {
                        _showControls();
                        _openLaps(timerState.laps, settings.dialAccentColor.value, settings.dialFaceStyle);
                      },
              ),
            ),
          ),
          (
            size: _tier3Size,
            child: _WearIconButton(
              icon: Icons.settings_outlined,
              size: _tier3Size,
              iconSize: _tier3Icon,
              tooltip: 'Settings',
              onPressed: () {
                _showControls();
                _openSettings();
              },
            ),
          ),
        ];

        return SizedBox(
          width: side,
          height: side,
          child: Stack(
            children: [
              Positioned(
                left: side / 2 - dialSize / 2,
                top: side / 2 - dialSize / 2,
                width: dialSize,
                height: dialSize,
                child: dialWithBackdrop,
              ),
              ..._curvedIconColumn(
                side: side,
                isLeft: true,
                controlsVisible: _controlsVisible,
                icons: leftIcons,
              ),
              ..._curvedIconColumn(
                side: side,
                isLeft: false,
                controlsVisible: _controlsVisible,
                icons: rightIcons,
              ),
            ],
          ),
        );
      },
    );

    final body = Stack(
      children: [
        Positioned.fill(child: Center(child: dialArea)),
        Positioned(
          left: 0,
          right: 0,
          // Icon buttons overlapping dial artwork (ticks, crown, the case
          // itself) is fine - overlapping the actual elapsed-time TEXT is
          // not, Wear OS requires the time stay legible. 10px (down from
          // 18) buys a bit more separation from Classic Stopwatch's
          // digital readout, which sits low enough in that face to
          // otherwise clash with this row once the dial got bigger.
          bottom: 10,
          child: Center(
            child: _Fadable(
              visible: _controlsVisible,
              child: _WearControls(timerState: timerState, onInteraction: _showControls),
            ),
          ),
        ),
      ],
    );

    // An ancestor GestureDetector, not a Stack sibling placed behind the
    // dial - CustomPaint marks itself hit-testable whenever it has a
    // painter (regardless of whether anything there actually listens for
    // taps), and Stack hit-testing stops at the first/topmost child that
    // claims a point, so a same-level sibling behind the dial never got a
    // chance to see the tap at all. Wrapping the whole screen instead
    // means this recognizer is in the hit-test path for every tap
    // (ancestors always are), reliably catching taps on the dial/blank
    // space; taps that land on a real button still also fire that
    // button's own onPressed - both recognizers can win independently -
    // which is fine, since every button already calls _showControls (or
    // onInteraction) itself anyway.
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showControls,
        child: SafeArea(child: body),
      ),
    );
  }
}

class _WearControls extends ConsumerWidget {
  const _WearControls({required this.timerState, required this.onInteraction});

  final TimerState timerState;
  // Lap doesn't change timerState.status (still running before and
  // after), so unlike Pause/Stop/Start/Resume - which the parent's
  // ref.listen already catches as entering/leaving the running state -
  // it needs its own explicit nudge to reset the auto-hide countdown.
  // Wiring all four the same way is simpler than treating Lap as a
  // special case.
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerNotifierProvider.notifier);

    VoidCallback tracked(VoidCallback action) {
      return () {
        action();
        onInteraction();
      };
    }

    return switch (timerState.status) {
      TimerStatus.idle => _WearIconButton(
          icon: Icons.play_arrow,
          size: _tier1Size,
          iconSize: _tier1Icon,
          filled: true,
          tooltip: 'Start',
          onPressed: tracked(notifier.start),
        ),
      TimerStatus.countingDown => _WearIconButton(
          icon: Icons.close,
          size: _tier1Size,
          iconSize: _tier1Icon,
          tooltip: 'Cancel',
          onPressed: tracked(notifier.stop),
        ),
      TimerStatus.running => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WearIconButton(icon: Icons.flag, size: _tier1Size, iconSize: _tier1Icon, tooltip: 'Lap', onPressed: tracked(notifier.lap)),
            const SizedBox(width: 16),
            _WearIconButton(icon: Icons.pause, size: _tier1Size, iconSize: _tier1Icon, filled: true, tooltip: 'Pause', onPressed: tracked(notifier.pause)),
          ],
        ),
      TimerStatus.paused => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WearIconButton(icon: Icons.stop, size: _tier1Size, iconSize: _tier1Icon, tooltip: 'Reset', onPressed: tracked(notifier.stop)),
            const SizedBox(width: 16),
            _WearIconButton(icon: Icons.play_arrow, size: _tier1Size, iconSize: _tier1Icon, filled: true, tooltip: 'Resume', onPressed: tracked(notifier.start)),
          ],
        ),
    };
  }
}

class _WearIconButton extends StatelessWidget {
  const _WearIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onPressed,
    this.filled = false,
    this.tooltip,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback? onPressed;
  final bool filled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // IconButton.filled/.outlined don't guarantee identical rendered sizes
    // against each other out of the box - explicit min/max size on the
    // style is what actually makes the three tiers read as three sizes
    // rather than "roughly similar."
    final style = IconButton.styleFrom(
      minimumSize: Size(size, size),
      maximumSize: Size(size, size),
      // Without this, Material still pads the button's actual layout
      // box out to its 48dp accessible tap target even though
      // minimumSize/maximumSize cap the painted circle at `size` - so a
      // Badge wrapping this button (which positions itself off that
      // larger invisible box, not the visible circle) floats detached
      // above the corner instead of overlapping it. shrinkWrap makes
      // the layout box match the visible circle exactly.
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const CircleBorder(),
      // Outlined buttons now sit directly on top of each face's own
      // artwork (ticks, hands, sub-dials) rather than a mostly-empty
      // margin - a bare 1px ring on transparent background read as thin
      // and easy to lose against that busier background. A translucent
      // dark fill gives every icon a consistent "chip" backdrop regardless
      // of what's rendered underneath - the fill alone turned out to
      // already do most of the work, so the ring only needs a touch more
      // than the 1px default, not the 2px first tried.
      backgroundColor: filled ? colorScheme.primary : Colors.black.withValues(alpha: 0.45),
      foregroundColor: filled ? colorScheme.onPrimary : colorScheme.onSurface,
      side: filled ? null : BorderSide(color: colorScheme.outline, width: 1.2),
    );

    return IconButton(
      style: style,
      iconSize: iconSize,
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
