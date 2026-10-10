import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_button/split_button.dart';

import '../../../core/widgets/view_constraint.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';
import 'widgets/lap_board.dart';
import 'widgets/watch_face.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  bool _isGlowing = false;

  void _toggleGlow() => setState(() => _isGlowing = !_isGlowing);

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TikTalk')),
      body: Stack(
        children: [
          SafeArea(
            child: ViewConstraint(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: WatchFace(
                          timerState: timerState,
                          dialFaceStyle: settings.dialFaceStyle,
                          accentColor: settings.dialAccentColor.value,
                          isGlowing: _isGlowing,
                        ),
                      ),
                    ),
                  ),
                  LapBoard(laps: timerState.laps, accentColor: settings.dialAccentColor.value),
                  _Controls(timerState: timerState),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              tooltip: 'Backlight',
              onPressed: _toggleGlow,
              child: Icon(_isGlowing ? Icons.lightbulb : Icons.lightbulb_outline),
            ),
          ),
        ],
      ),
    );
  }
}


class _Controls extends ConsumerWidget {
  const _Controls({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (timerState.status == TimerStatus.idle) {
            final countdownSeconds = ref.watch(settingsNotifierProvider).countdownSeconds;
            return _StartSplitButton(
              width: constraints.maxWidth,
              countdownSeconds: countdownSeconds,
              onStart: notifier.start,
              onCountdownSecondsChanged:
                  ref.read(settingsNotifierProvider.notifier).updateCountdownSeconds,
            );
          }

          if (timerState.status == TimerStatus.countingDown) {
            return SizedBox(
              width: constraints.maxWidth,
              child: _SecondaryButton(label: 'Cancel', onPressed: notifier.stop),
            );
          }

          final buttons = switch (timerState.status) {
            TimerStatus.running => [
                _SecondaryButton(label: 'Lap', onPressed: notifier.lap),
                _PrimaryButton(label: 'Pause', onPressed: notifier.pause),
              ],
            TimerStatus.paused => [
                _SecondaryButton(label: 'Reset', onPressed: notifier.stop),
                _PrimaryButton(label: 'Resume', onPressed: notifier.start),
              ],
            _ => const <Widget>[],
          };

          return Row(
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: buttons[i]),
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
    required this.countdownSeconds,
    required this.onStart,
    required this.onCountdownSecondsChanged,
  });

  static const _countdownOptions = [0, 3, 5, 10, 20, 30];

  final double width;
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
                child: Text(seconds == 0 ? 'No countdown' : '${seconds}s countdown'),
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
  Widget build(BuildContext context) => FilledButton(onPressed: onPressed, child: Text(label));
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(onPressed: onPressed, child: Text(label));
}
