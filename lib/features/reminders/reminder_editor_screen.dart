import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import 'reminder_labels.dart';

/// Edits or creates a reminder. Pops true after saving.
class ReminderEditorScreen extends ConsumerStatefulWidget {
  const ReminderEditorScreen(this.reminder, {super.key});

  final Reminder reminder;

  @override
  ConsumerState<ReminderEditorScreen> createState() =>
      _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends ConsumerState<ReminderEditorScreen> {
  late Reminder _draft = widget.reminder;
  bool _saving = false;

  void _change(Reminder draft) => setState(() => _draft = draft);

  Future<int?> _pickTime(int initial) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    return time == null ? null : time.hour * 60 + time.minute;
  }

  Future<void> _save(Reminder reminder) async {
    setState(() => _saving = true);
    try {
      await ref.read(reminderRepositoryProvider).save(reminder);
      if (mounted) Navigator.of(context).pop(true);
    } on ReminderException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(problemText(e.problem))));
    }
  }

  Future<void> _delete() async {
    await ref.read(reminderRepositoryProvider).delete(_draft.id!);
    if (mounted) Navigator.of(context).pop(false);
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _timeButton(String label, int minute, ValueChanged<int> onPicked) =>
      Expanded(
        child: OutlinedButton(
          onPressed: () async {
            final picked = await _pickTime(minute);
            if (picked != null && mounted) onPicked(picked);
          },
          child: Text('$label ${formatMinute(minute)}'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final routine = ref.watch(routineProvider).value ?? const <RoutineItem>[];
    final others = ref.watch(remindersProvider).value ?? const <Reminder>[];
    final exercises = ref.watch(exerciseMapProvider);
    // Items may have been removed from the routine since they were chosen.
    final draft = _draft.copyWith(
      itemIds: _draft.itemIds.intersection({for (final i in routine) i.id}),
    );
    final problem = reminderProblem(draft, others);
    final slots = distinctTimes([
      for (final r in others)
        if (draft.id == null || r.id != draft.id) r,
      draft.copyWith(enabled: true),
    ]).length;
    final firesAt = draft.fireTimes.map(formatMinute).join(', ');

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<ReminderType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ReminderType.interval,
                label: Text('Interval'),
              ),
              ButtonSegment(
                value: ReminderType.times,
                label: Text('Set times'),
              ),
            ],
            selected: {draft.type},
            onSelectionChanged: (s) => _change(_draft.copyWith(type: s.single)),
          ),
          if (draft.type == ReminderType.interval) ...[
            _heading('Every'),
            DropdownButton<int>(
              isExpanded: true,
              value: draft.intervalMinutes,
              items: [
                for (final m in reminderIntervals)
                  DropdownMenuItem(value: m, child: Text(intervalLabel(m))),
              ],
              onChanged: (m) => _change(_draft.copyWith(intervalMinutes: m)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _timeButton(
                  'From',
                  draft.startMinute,
                  (m) => _change(_draft.copyWith(startMinute: m)),
                ),
                const SizedBox(width: 12),
                _timeButton(
                  'To',
                  draft.endMinute,
                  (m) => _change(_draft.copyWith(endMinute: m)),
                ),
              ],
            ),
          ] else ...[
            _heading('Times'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in draft.fireTimes)
                  InputChip(
                    label: Text(formatMinute(m)),
                    onDeleted: () => _change(
                      _draft.copyWith(
                        times: [
                          for (final t in _draft.times)
                            if (t != m) t,
                        ],
                      ),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text('Add time'),
                  onPressed: () async {
                    final m = await _pickTime(12 * 60);
                    if (m == null || !mounted) return;
                    _change(
                      _draft.copyWith(times: {..._draft.times, m}.toList()),
                    );
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text('Fires at: ${firesAt.isEmpty ? '—' : firesAt}'),
          const SizedBox(height: 4),
          Text('$slots of $maxPending notification slots needed'),
          _heading('Exercises'),
          SegmentedButton<ReminderScope>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ReminderScope.nextUp,
                label: Text('Next up'),
              ),
              ButtonSegment(value: ReminderScope.all, label: Text('All')),
              ButtonSegment(value: ReminderScope.chosen, label: Text('Choose')),
            ],
            selected: {draft.scope},
            onSelectionChanged: (s) =>
                _change(_draft.copyWith(scope: s.single)),
          ),
          if (draft.scope == ReminderScope.nextUp)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Gives the next stretches not yet done today.'),
            ),
          if (draft.scope == ReminderScope.chosen)
            for (final item in routine)
              CheckboxListTile(
                title: Text(
                  exercises[item.exerciseId]?.name ?? item.exerciseId,
                ),
                value: draft.itemIds.contains(item.id),
                onChanged: (on) => _change(
                  _draft.copyWith(
                    itemIds: on!
                        ? {...draft.itemIds, item.id}
                        : draft.itemIds.difference({item.id}),
                  ),
                ),
              ),
          const SizedBox(height: 20),
          if (problem != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                problemText(problem),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton(
            onPressed: problem != null || _saving ? null : () => _save(draft),
            child: const Text('Save'),
          ),
          if (draft.id != null)
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }
}
