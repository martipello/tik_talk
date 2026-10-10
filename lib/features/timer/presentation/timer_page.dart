import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_button/split_button.dart';

import '../../../core/extensions/duration_extension.dart';
import '../../../core/widgets/view_constraint.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';
import 'widgets/watch_face.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final dialTheme = ref.watch(settingsNotifierProvider).dialTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('TikTalk')),
      body: SafeArea(
        child: ViewConstraint(
          child: Column(
            children: [
              Expanded(
                child: Center(child: WatchFace(timerState: timerState, dialTheme: dialTheme)),
              ),
              _LapList(laps: timerState.laps),
              _Controls(timerState: timerState),
            ],
          ),
        ),
      ),
    );
  }
}

class _LapList extends StatelessWidget {
  const _LapList({required this.laps});

  final List<Duration> laps;

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: laps.length,
        itemBuilder: (context, index) => ListTile(
          dense: true,
          leading: Text('Lap ${index + 1}'),
          title: Text(laps[index].formattedClock),
        ),
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
            final countInSeconds = ref.watch(settingsNotifierProvider).countInSeconds;
            return _StartSplitButton(
              width: constraints.maxWidth,
              countInSeconds: countInSeconds,
              onStart: notifier.start,
              onCountInChanged: ref.read(settingsNotifierProvider.notifier).updateCountInSeconds,
            );
          }

          if (timerState.status == TimerStatus.countingIn) {
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
    required this.countInSeconds,
    required this.onStart,
    required this.onCountInChanged,
  });

  static const _countInOptions = [0, 10, 20, 30];

  final double width;
  final int countInSeconds;
  final VoidCallback onStart;
  final ValueChanged<int> onCountInChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SplitButton<int>(
      width: width,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      onPressed: onStart,
      title: const Text('Start'),
      action: Text('+$countInSeconds'),
      onChanged: onCountInChanged,
      popupList: _countInOptions
          .map(
            (seconds) => SplitButtonEntry(
              value: seconds,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(seconds == 0 ? 'No count-in' : '${seconds}s count-in'),
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
