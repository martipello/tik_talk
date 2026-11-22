import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_time_extension.dart';
import '../../../core/extensions/duration_extension.dart';
import '../../timer/providers/timer_notifier.dart';
import '../data/timer_session.dart';
import '../providers/history_notifier.dart';

class WearHistoryScreen extends ConsumerWidget {
  const WearHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(historyNotifierProvider);

    // Scrolls away with everything else rather than sitting pinned on top
    // of it - Wear OS treats a fixed overlay that content can't scroll
    // clear of as broken UX, not just a style choice (this used to be a
    // Positioned overlay for exactly this reason and read as "overlapping"
    // no matter where it sat).
    final backButton = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: sessionsAsync.when(
          data: (sessions) => sessions.isEmpty
              ? Column(
                  children: [
                    // Same bezel-clearance padding as the non-empty branch
                    // below and wear_settings_screen.dart - EdgeInsets.all(12)
                    // here clipped the back arrow against the round bezel.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 44,
                      ),
                      child: backButton,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No sessions yet',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  // See the matching comment in wear_settings_screen.dart -
                  // generous uniform padding to clear the round bezel.
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 44,
                  ),
                  itemCount: sessions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return backButton;
                    final session = sessions[index - 1];
                    return _WearHistoryTile(
                      session: session,
                      // This screen is now a pushed route (not a PageView
                      // page), so resuming just pops straight back to the
                      // Timer screen underneath, which already watches
                      // the same (keepAlive) TimerNotifier and will show
                      // the resumed state immediately.
                      onTap: session.id == null
                          ? null
                          : () {
                              ref
                                  .read(timerNotifierProvider.notifier)
                                  .resumeSession(session);
                              Navigator.of(context).pop();
                            },
                    );
                  },
                ),
          error: (error, stackTrace) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 44,
                ),
                child: backButton,
              ),
              const Expanded(
                child: Center(
                  child: Text('Failed to load', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
          loading: () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 44,
                ),
                child: backButton,
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
    );
  }
}

class _WearHistoryTile extends StatelessWidget {
  const _WearHistoryTile({required this.session, required this.onTap});

  final TimerSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final label = session.label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Centred, not left-aligned like the phone's ListTile - text near
        // the left/right edges of a round screen gets visually cramped by
        // the bezel curve, centred text doesn't have that problem.
        child: Column(
          children: [
            Text(
              label ?? session.duration.formattedClock,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              label == null
                  ? session.completedAt.formattedHistoryTimestamp
                  : '${session.duration.formattedClock} · ${session.completedAt.formattedHistoryTimestamp}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
