import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_mode.dart';
import '../providers/timer_notifier.dart';
import '../providers/timer_state.dart';
import '../providers/timer_status.dart';

class WearTimerScreen extends ConsumerWidget {
  const WearTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(timerState.displayDuration),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _WearControls(timerState: timerState),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _WearControls extends ConsumerWidget {
  const _WearControls({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerNotifierProvider.notifier);

    return switch (timerState.status) {
      TimerStatus.idle => IconButton(
          iconSize: 36,
          icon: const Icon(Icons.play_arrow),
          onPressed: timerState.mode == TimerMode.countdown
              ? notifier.startCountdownTimer
              : notifier.start,
        ),
      TimerStatus.running => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(iconSize: 28, icon: const Icon(Icons.flag), onPressed: notifier.lap),
            IconButton(iconSize: 36, icon: const Icon(Icons.pause), onPressed: notifier.pause),
          ],
        ),
      TimerStatus.paused => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(iconSize: 28, icon: const Icon(Icons.stop), onPressed: notifier.stop),
            IconButton(iconSize: 36, icon: const Icon(Icons.play_arrow), onPressed: notifier.start),
          ],
        ),
      TimerStatus.finished => IconButton(
          iconSize: 36,
          icon: const Icon(Icons.refresh),
          onPressed: notifier.stop,
        ),
    };
  }
}
