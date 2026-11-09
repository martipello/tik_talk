import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/date_time_extension.dart';
import '../../../core/extensions/duration_extension.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/models/lap.dart';
import '../../../core/utils/lap_records.dart';
import '../../../core/widgets/text_prompt_dialog.dart';
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

  Future<void> _relabelSession(TimerSession session) async {
    final label = await showTextPromptDialog(
      context,
      title: 'Name this session',
      initialValue: session.label,
    );
    if (label == null || session.id == null) return;
    await ref
        .read(historyNotifierProvider.notifier)
        .relabelSession(session.id!, label.isEmpty ? null : label);
  }

  Future<void> _relabelLap(TimerSession session, int lapIndex) async {
    if (session.id == null) return;
    final label = await showTextPromptDialog(
      context,
      title: 'Label lap ${lapIndex + 1}',
      initialValue: session.laps[lapIndex].label,
    );
    if (label == null) return;
    await ref
        .read(historyNotifierProvider.notifier)
        .relabelLap(session.id!, lapIndex, label.isEmpty ? null : label);
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(historyNotifierProvider);

    // The selection toolbar is an action bar (close/delete), not a title bar,
    // so it stays even when the rail replaces the plain "History" title bar.
    final appBar = _isSelecting
        ? AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            ),
            title: Text('${_selectedIds.length} selected'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteSelected,
              ),
            ],
          )
        : AppBreakpoints.isWide(context)
        ? null
        : AppBar(title: const Text('History'));

    return Scaffold(
      appBar: appBar,
      body: ViewConstraint(
        child: sessionsAsync.when(
          data: (sessions) => sessions.isEmpty
              ? const _EmptyHistory()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final id = session.id;

                    return _HistoryCard(
                      session: session,
                      isSelected: id != null && _selectedIds.contains(id),
                      isSelecting: _isSelecting,
                      onTap: id == null
                          ? null
                          : _isSelecting
                          ? () => _toggleSelection(id)
                          : () => _resumeSession(session),
                      onLongPress: id == null
                          ? null
                          : () => _toggleSelection(id),
                      onEditLabel: id == null
                          ? null
                          : () => _relabelSession(session),
                      onEditLap: id == null
                          ? null
                          : (lapIndex) => _relabelLap(session, lapIndex),
                    );
                  },
                ),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load history: $error')),
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
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
    required this.onEditLabel,
    required this.onEditLap,
  });

  final TimerSession session;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEditLabel;
  final ValueChanged<int>? onEditLap;

  @override
  Widget build(BuildContext context) {
    final label = session.label;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                onTap: onTap,
                onLongPress: onLongPress,
                leading: Icon(isSelected ? Icons.check_circle : Icons.timer_outlined),
                title: Text(label ?? session.duration.formattedClock),
                subtitle: Text(
                  label == null
                      ? session.completedAt.formattedHistoryTimestamp
                      : '${session.duration.formattedClock} · ${session.completedAt.formattedHistoryTimestamp}',
                ),
                trailing: onEditLabel == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEditLabel,
                      ),
              ),
              if (session.laps.isNotEmpty)
                _HistoryLapList(laps: session.laps, onLapTap: onEditLap),
            ],
          ),
          // While multi-select is active, the edit-label button and the lap
          // rows below would otherwise still handle their own taps first
          // (opening a rename dialog instead of toggling selection) - this
          // sits on top of the whole card and, being opaque to hit testing,
          // swallows every tap/long-press itself so the card always just
          // selects, no matter where on it you tap.
          if (isSelecting)
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, onLongPress: onLongPress),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryLapList extends StatelessWidget {
  const _HistoryLapList({required this.laps, this.onLapTap});

  final List<Lap> laps;
  final ValueChanged<int>? onLapTap;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final records = buildLapRecords(laps);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          for (final record in records)
            InkWell(
              onTap: onLapTap == null ? null : () => onLapTap!(record.lapNumber - 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('Lap ${record.lapNumber}', style: TextStyle(color: mutedColor, fontSize: 13)),
                    const SizedBox(width: 8),
                    if (record.label != null)
                      Expanded(
                        child: Text(
                          record.label!,
                          style: TextStyle(color: mutedColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    Text(record.split.formattedClock, style: TextStyle(color: mutedColor, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
