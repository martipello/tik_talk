import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_time_extension.dart';
import '../../../core/extensions/duration_extension.dart';
import '../../../core/widgets/view_constraint.dart';
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
              ? const Center(child: Text('No sessions yet'))
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final id = session.id;

                    return _HistoryTile(
                      session: session,
                      isSelected: id != null && _selectedIds.contains(id),
                      onTap: id == null || !_isSelecting ? null : () => _toggleSelection(id),
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
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
    return ListTile(
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Icon(isSelected ? Icons.check_circle : Icons.timer_outlined),
      title: Text(session.duration.formattedClock),
      subtitle: Text(session.completedAt.formattedHistoryTimestamp),
      trailing: session.laps.isEmpty ? null : Text('${session.laps.length} laps'),
    );
  }
}
