import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/duration_extension.dart';
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
                timerState.status == TimerStatus.countingIn
                    ? timerState.countInSecondsRemaining.toString()
                    : timerState.elapsed.formattedClock,
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
          onPressed: notifier.start,
        ),
      TimerStatus.countingIn => IconButton(
          iconSize: 36,
          icon: const Icon(Icons.close),
          onPressed: notifier.stop,
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
    };
  }
}
