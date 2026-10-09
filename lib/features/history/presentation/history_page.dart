import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../timer/providers/timer_mode.dart';
import '../data/timer_session.dart';
import '../providers/history_notifier.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _confirmDeleteAll(context, ref),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) => sessions.isEmpty
            ? const Center(child: Text('No sessions yet'))
            : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) => _HistoryTile(session: sessions[index]),
              ),
        error: (error, stackTrace) => Center(child: Text('Failed to load history: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all sessions?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete all')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyNotifierProvider.notifier).deleteAll();
    }
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.session});

  final TimerSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = ListTile(
      leading: Icon(
        session.mode == TimerMode.countdown ? Icons.hourglass_bottom : Icons.timer_outlined,
      ),
      title: Text(_formatDuration(session.duration)),
      subtitle: Text(session.completedAt.toLocal().toString()),
      trailing: session.laps.isEmpty ? null : Text('${session.laps.length} laps'),
    );

    final id = session.id;
    if (id == null) return tile;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(historyNotifierProvider.notifier).deleteSession(id),
      child: tile,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
