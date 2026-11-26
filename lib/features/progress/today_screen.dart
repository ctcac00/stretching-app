import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/settings_card.dart';
import '../../core/providers.dart';
import '../../core/ui/exercise_image.dart';
import '../session/session_launcher.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _selected = <int>{};
  late final Timer _timer;
  late DateTime _shown;

  @override
  void initState() {
    super.initState();
    _shown = ref.read(clockProvider)();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTime());
  }

  /// Next up (Auto) and the next reminder change with the minute, and everything
  /// with the date.
  void _onTime() {
    final now = ref.read(clockProvider)();
    final newDay = localDate(now) != localDate(_shown);
    if (!newDay && minuteOfDay(now) == minuteOfDay(_shown)) return;
    if (newDay) ref.invalidate(todayProvider);
    ref.invalidate(nextUpProvider);
    setState(() => _shown = now);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routine = ref.watch(routineProvider).value;
    final done = ref.watch(doneTodayProvider).value ?? const {};
    final upNext = ref.watch(nextUpProvider);
    final perSession = ref.watch(settingsProvider).value?.perSession;
    final reminders = ref.watch(remindersProvider).value;
    final sessions = ref.watch(todaySessionsProvider).value ?? const [];
    final exercises = ref.watch(exerciseMapProvider);

    final items = routine ?? const <RoutineItem>[];
    final total = items.length;
    final count = items.where((i) => done.contains(i.id)).length;
    final fraction = total == 0 ? 0.0 : count / total;
    final picked = [
      for (final i in items)
        if (_selected.contains(i.id)) i.id,
    ];
    // Nothing more is scheduled today once the routine is done.
    final allDone = total > 0 && count == total;
    final now = ref.read(clockProvider)();
    final next = reminders == null
        ? null
        : nextReminder(
            reminders,
            allDone ? DateTime(now.year, now.month, now.day, 23, 59) : now,
          );
    String name(RoutineItem item) =>
        exercises[item.exerciseId]?.name ??
        (exercises.isEmpty ? '' : 'Unknown exercise');

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.outlineVariant,
                    value: fraction,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(fraction * 100).round()}%',
                        style: theme.textTheme.displaySmall,
                      ),
                      Text('$count of $total done'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: picked.isNotEmpty
                  ? () {
                      setState(_selected.clear);
                      openSession(picked);
                    }
                  : upNext == null || upNext.isEmpty
                  ? null
                  : openNextUpSession,
              child: Text(
                picked.isNotEmpty
                    ? 'Start ${picked.length} selected'
                    : routine == null || upNext == null
                    ? 'Loading'
                    : upNext.isNotEmpty
                    ? 'Start next ${upNext.length}'
                    : total > 0
                    ? 'All done for today'
                    : 'Routine is empty',
              ),
            ),
          ),
          if (picked.isEmpty && upNext != null && upNext.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                upNext.map(name).join(' · '),
                textAlign: TextAlign.center,
              ),
            ),
          heading('Stretches per session'),
          if (perSession != null)
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final n in [0, 1, 2, 3])
                  ButtonSegment(value: n, label: Text(n == 0 ? 'Auto' : '$n')),
              ],
              selected: {perSession},
              onSelectionChanged: (s) =>
                  ref.read(settingsRepositoryProvider).setPerSession(s.single),
            ),
          const SizedBox(height: 8),
          const Text(
            'Auto spreads what is left over today’s remaining reminders.',
          ),
          heading('Or tap to pick one or more'),
          for (final item in items)
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                selected: _selected.contains(item.id),
                selectedTileColor: theme.colorScheme.primaryContainer,
                leading: ExerciseImage(
                  exercises[item.exerciseId],
                  width: 56,
                  height: 56,
                ),
                title: Text(name(item)),
                subtitle: Text(
                  '${item.value} '
                  '${item.mode == ExerciseMode.time ? 's' : 'reps'}'
                  '${item.sides == Sides.leftRight ? ' · left + right' : ''}'
                  '${done.contains(item.id) ? ' · ✓ done today' : ''}',
                ),
                trailing: Icon(
                  _selected.contains(item.id)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                onTap: () => setState(() {
                  if (!_selected.remove(item.id)) _selected.add(item.id);
                }),
              ),
            ),
          OutlinedButton(
            onPressed: total == 0
                ? null
                : () {
                    setState(_selected.clear);
                    openSession([for (final i in items) i.id]);
                  },
            child: const Text('Start whole routine'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: count == total
                ? null
                : ref.read(sessionRepositoryProvider).markRoutineDone,
            child: const Text('Mark routine done'),
          ),
          heading('Next reminder'),
          Card(
            child: ListTile(
              title: Text(
                next == null
                    ? 'None set.'
                    : '${allDone ? 'Tomorrow ' : ''}'
                          '${formatMinute(next.minute)} · '
                          '${next.reminder.scopeLabel}',
              ),
            ),
          ),
          heading('Sessions today'),
          if (sessions.isEmpty) const Text('Nothing yet.'),
          for (final session in sessions)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check),
                title: Text(
                  '${formatMinute(session.minute)} · '
                  '${session.itemIds.length} '
                  '${session.itemIds.length == 1 ? 'exercise' : 'exercises'}',
                ),
              ),
            ),
          heading('Settings'),
          const SettingsCard(),
        ],
      ),
    );
  }
}
