import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/dial_face_style.dart';
import '../../../core/widgets/bottom_button_holder.dart';
import '../../../core/widgets/split_button.dart';
import '../../../core/widgets/text_prompt_dialog.dart';
import '../../../core/widgets/view_constraint.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';
import 'widgets/fluid_glass_background.dart';
import 'widgets/lap_board.dart';
import 'widgets/watch_face.dart';

// Shared by the watch face/lap list column and the controls below it, so the
// whole page reads as one consistent-width column on wide/web layouts
// instead of the dial stretching out to the page's general 960px cap while
// the button bar stays narrow.
const double _timerContentMaxWidth = 480;

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  bool _isGlowing = false;

  void _toggleGlow() => setState(() => _isGlowing = !_isGlowing);

  Future<void> _relabelLap(int index, TimerState timerState) async {
    final label = await showTextPromptDialog(
      context,
      title: 'Label lap ${index + 1}',
      initialValue: timerState.laps[index].label,
    );
    if (label == null || !mounted) return;
    ref.read(timerNotifierProvider.notifier).relabelLap(index, label.isEmpty ? null : label);
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    // On web/wide layouts there's no AppBar (see below) to give the dial
    // breathing room from the top of the window, so it needs more of its
    // own top padding than the mobile layout, which already has the AppBar.
    final watchFaceTopPadding = AppBreakpoints.isWide(context) ? 48.0 : 16.0;

    // TimerPage is a branch of a StatefulShellRoute (bottom tabs), where
    // Scaffold.body doesn't reliably give a Stack tight/bounded constraints
    // the way it does for a top-level pushed route - a Stack+Positioned.fill
    // here silently fails to render. Column+Expanded is the robust pattern
    // for this situation (matches how Pitch-In handles the same nesting).
    return Scaffold(
      appBar: AppBreakpoints.isWide(context)
          ? null
          : AppBar(title: const Text('TikTalk')),
      body: Column(
        children: [
          Expanded(
            child: _TimerStage(
              dialFaceStyle: settings.dialFaceStyle,
              accentColor: settings.dialAccentColor.value,
              sessionLabel: timerState.label,
              scrollableContent: SafeArea(
                bottom: false,
                child: ViewConstraint(
                  constraints: const BoxConstraints(
                    maxWidth: _timerContentMaxWidth,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          watchFaceTopPadding,
                          24,
                          16,
                        ),
                        child: WatchFace(
                          timerState: timerState,
                          dialFaceStyle: settings.dialFaceStyle,
                          accentColor: settings.dialAccentColor.value,
                          isGlowing: _isGlowing,
                        ),
                      ),
                      LapBoard(
                        laps: timerState.laps,
                        accentColor: settings.dialAccentColor.value,
                        dialFaceStyle: settings.dialFaceStyle,
                        onLapTap: (index) => _relabelLap(index, timerState),
                      ),
                    ],
                  ),
                ),
              ),
              glowButton: FloatingActionButton.small(
                tooltip: 'Backlight',
                onPressed: _toggleGlow,
                child: Icon(
                  _isGlowing ? Icons.lightbulb : Icons.lightbulb_outline,
                ),
              ),
              muteButton: FloatingActionButton.small(
                tooltip: settings.ttsMuted
                    ? 'Unmute announcements'
                    : 'Mute announcements',
                onPressed: () => ref
                    .read(settingsNotifierProvider.notifier)
                    .updateTtsMuted(!settings.ttsMuted),
                child: Icon(
                  settings.ttsMuted ? Icons.volume_off : Icons.volume_up,
                ),
              ),
            ),
          ),
          BottomButtonHolder(child: _Controls(timerState: timerState)),
        ],
      ),
    );
  }
}

// OCLiquidGlassGroup wraps a subtree with a single shared backdrop-filter
// shader; any OCLiquidGlass descendant (the 3 orbs, arbitrarily nested
// inside WatchFace) registers itself with this ancestor and gets refracted,
// using whatever is painted earlier in this same subtree as the backdrop -
// hence FluidGlassBackground needs to be a normal Stack child here (painted
// first/behind), not a separate "background" parameter.
class _TimerStage extends StatelessWidget {
  const _TimerStage({
    required this.dialFaceStyle,
    required this.accentColor,
    required this.scrollableContent,
    required this.glowButton,
    required this.muteButton,
    this.sessionLabel,
  });

  final DialFaceStyle dialFaceStyle;
  final Color accentColor;
  final Widget scrollableContent;
  final Widget glowButton;
  final Widget muteButton;
  final String? sessionLabel;

  // Caps how wide the title can grow before eliding, so a long session name
  // doesn't stretch across the whole stage - just a constrained label in the
  // corner, not a second header competing with the dial.
  static const _sessionLabelMaxWidth = 220.0;

  // FloatingActionButton.small is a fixed 40dp, and the mute button sits
  // directly below the glow one with its own gap beneath that - large
  // enough that the two don't read as one control, per request ("enough
  // separation that it isn't in the same vicinity").
  static const _fabSize = 40.0;
  static const _fabGap = 24.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The glow/mute FABs should sit in the content column's top-right
        // corner (same as the watch face/lap list below it), not the full
        // page's - on a wide/web window the content column is centered and
        // narrower than the page, so its right edge isn't at the page's
        // right edge.
        final contentWidth = constraints.maxWidth.clamp(
          0.0,
          _timerContentMaxWidth,
        );
        final horizontalInset = (constraints.maxWidth - contentWidth) / 2;
        // On wide/web windows, anchoring the FABs flush to the content
        // column's edge leaves them stranded far from the window's actual
        // edge. Split the difference instead: inset only half as far as the
        // content column, so the FABs sit midway between there and the edge.
        final fabRightInset = horizontalInset / 2 + 16;

        final stack = Stack(
          children: [
            if (dialFaceStyle.usesGlassBackdrop)
              Positioned.fill(
                child: FluidGlassBackground(accentColor: accentColor),
              ),
            Positioned.fill(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(child: scrollableContent),
                ),
              ),
            ),
            Positioned(top: 16, right: fabRightInset, child: glowButton),
            Positioned(
              top: 16 + _fabSize + _fabGap,
              right: fabRightInset,
              child: muteButton,
            ),
            if (sessionLabel != null)
              Positioned(
                top: 16,
                left: horizontalInset + 16,
                child: ViewConstraint(
                  expand: false,
                  constraints: const BoxConstraints(maxWidth: _sessionLabelMaxWidth),
                  child: Text(
                    sessionLabel!,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );

        if (!dialFaceStyle.usesGlassBackdrop) return stack;

        return OCLiquidGlassGroup(
          settings: const OCLiquidGlassSettings(blurRadiusPx: 4),
          child: stack,
        );
      },
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.timerState});

  final TimerState timerState;

  // All four button states (Start, Cancel, Lap/Pause, Reset/Resume) share
  // this one cap, via ViewConstraint below, so the bar never changes width
  // as the timer moves between states. Narrower than _timerContentMaxWidth:
  // SplitButton forces its popup menu to exactly match whatever width Start
  // gets (see _StartSplitButton), and the full 480 broke the popup's own
  // layout on wide web windows (not enough room for it near the right edge,
  // shadow clipped).
  static const _controlsMaxWidth = 320.0;

  // Every state (1 or 2 buttons) renders through the same Row-of-Expanded
  // below, each pinned to this height, so Start/Cancel/Lap/Pause/Reset/Resume
  // are always identical sizes rather than each following its own button
  // type's intrinsic size.
  static const _buttonHeight = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerNotifierProvider.notifier);

    return ViewConstraint(
      constraints: const BoxConstraints(maxWidth: _controlsMaxWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final List<Widget> buttons;
          if (timerState.status == TimerStatus.idle) {
            final countdownSeconds = ref
                .watch(settingsNotifierProvider)
                .countdownSeconds;
            buttons = [
              _StartSplitButton(
                width: constraints.maxWidth,
                height: _buttonHeight,
                countdownSeconds: countdownSeconds,
                onStart: notifier.start,
                onCountdownSecondsChanged: ref
                    .read(settingsNotifierProvider.notifier)
                    .updateCountdownSeconds,
              ),
            ];
          } else {
            buttons = switch (timerState.status) {
              TimerStatus.countingDown => [
                _SecondaryButton(label: 'Cancel', onPressed: notifier.stop),
              ],
              TimerStatus.running => [
                _SecondaryButton(label: 'Lap', onPressed: notifier.lap),
                _PrimaryButton(label: 'Pause', onPressed: notifier.pause),
              ],
              TimerStatus.paused => [
                _SecondaryButton(label: 'Reset', onPressed: notifier.stop),
                _PrimaryButton(label: 'Resume', onPressed: notifier.start),
              ],
              TimerStatus.idle => const <Widget>[],
            };
          }

          return Row(
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(height: _buttonHeight, child: buttons[i]),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StartSplitButton extends StatelessWidget {
  const _StartSplitButton({
    required this.width,
    required this.height,
    required this.countdownSeconds,
    required this.onStart,
    required this.onCountdownSecondsChanged,
  });

  static const _countdownOptions = [0, 3, 5, 10, 20, 30];

  final double width;
  final double height;
  final int countdownSeconds;
  final VoidCallback onStart;
  final ValueChanged<int> onCountdownSecondsChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonTextStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary);

    return SplitButton<int>(
      width: width,
      height: height,
      elevation: 1,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      onPressed: onStart,
      title: Text('Start', style: buttonTextStyle),
      action: Text('+$countdownSeconds', style: buttonTextStyle),
      onChanged: onCountdownSecondsChanged,
      popupList: _countdownOptions
          .map(
            (seconds) => SplitButtonEntry(
              value: seconds,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  seconds == 0 ? 'No countdown' : '${seconds}s countdown',
                  style: buttonTextStyle,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: Text(label));
}
