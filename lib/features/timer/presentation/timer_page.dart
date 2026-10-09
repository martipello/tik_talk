import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_mode.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TikTalk')),
      body: SafeArea(
        child: Column(
          children: [
            _ModeSelector(timerState: timerState),
            Expanded(child: Center(child: _DialPlaceholder(timerState: timerState))),
            _LapList(laps: timerState.laps),
            _Controls(timerState: timerState),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIdle = timerState.status == TimerStatus.idle;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SegmentedButton<TimerMode>(
        segments: const [
          ButtonSegment(value: TimerMode.stopwatch, label: Text('Stopwatch')),
          ButtonSegment(value: TimerMode.countdown, label: Text('Countdown')),
        ],
        selected: {timerState.mode},
        onSelectionChanged: isIdle
            ? (selection) => ref.read(timerNotifierProvider.notifier).setMode(selection.first)
            : null,
      ),
    );
  }
}

class _DialPlaceholder extends StatelessWidget {
  const _DialPlaceholder({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(timerState.displayDuration),
      style: Theme.of(context).textTheme.displayMedium,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (duration.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
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
          title: Text(_formatLap(laps[index])),
        ),
      ),
    );
  }

  String _formatLap(Duration lap) {
    final minutes = lap.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = lap.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
      child: switch (timerState.status) {
        TimerStatus.idle => _PrimaryButton(
            label: timerState.mode == TimerMode.countdown ? 'Start countdown' : 'Start',
            onPressed:
                timerState.mode == TimerMode.countdown ? notifier.startCountdownTimer : notifier.start,
          ),
        TimerStatus.running => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SecondaryButton(label: 'Lap', onPressed: notifier.lap),
              _PrimaryButton(label: 'Pause', onPressed: notifier.pause),
            ],
          ),
        TimerStatus.paused => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SecondaryButton(label: 'Reset', onPressed: notifier.stop),
              _PrimaryButton(label: 'Resume', onPressed: notifier.start),
            ],
          ),
        TimerStatus.finished => _PrimaryButton(label: 'Reset', onPressed: notifier.stop),
      },
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
