import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/date_time_extension.dart';
import '../../../core/extensions/duration_extension.dart';
import '../../../core/widgets/view_constraint.dart';
import '../../timer/providers/timer_notifier.dart';
import '../data/timer_session.dart';
import '../providers/history_notifier.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final Set<int> _selectedIds = {};

  bool get _isSelecting => _selectedIds.isNotEmpty;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  Future<void> _deleteSelected() async {
    final notifier = ref.read(historyNotifierProvider.notifier);
    for (final id in _selectedIds) {
      await notifier.deleteSession(id);
    }
    _clearSelection();
  }

  void _resumeSession(TimerSession session) {
    ref.read(timerNotifierProvider.notifier).resumeSession(session);
    if (!mounted) return;
    context.go('/timer');
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: _isSelecting
          ? AppBar(
              leading: IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection),
              title: Text('${_selectedIds.length} selected'),
              actions: [
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteSelected),
              ],
            )
          : AppBar(title: const Text('History')),
      body: ViewConstraint(
        child: sessionsAsync.when(
          data: (sessions) => sessions.isEmpty
              ? const _EmptyHistory()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final id = session.id;

                    return _HistoryCard(
                      session: session,
                      isSelected: id != null && _selectedIds.contains(id),
                      onTap: id == null
                          ? null
                          : _isSelecting
                              ? () => _toggleSelection(id)
                              : () => _resumeSession(session),
                      onLongPress: id == null ? null : () => _toggleSelection(id),
                    );
                  },
                ),
          error: (error, stackTrace) => Center(child: Text('Failed to load history: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 56, color: mutedColor),
          const SizedBox(height: 12),
          Text('No sessions yet', style: TextStyle(color: mutedColor)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final TimerSession session;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Icon(isSelected ? Icons.check_circle : Icons.timer_outlined),
        title: Text(session.duration.formattedClock),
        subtitle: Text(session.completedAt.formattedHistoryTimestamp),
        trailing: session.laps.isEmpty ? null : Text('${session.laps.length} laps'),
      ),
    );
  }
}
