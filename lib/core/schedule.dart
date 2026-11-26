/// Reminder times and next-up logic. Pure Dart: no Flutter imports.
library;

import 'dart:math';

import 'clock.dart';
import 'db/database.dart';
import 'models/reminder.dart';

/// iOS limit of pending notifications, and so of distinct reminder times.
const maxPending = 64;

/// Distinct times of day across all enabled reminders, sorted.
List<int> distinctTimes(Iterable<Reminder> reminders) => {
  for (final r in reminders)
    if (r.enabled) ...r.fireTimes,
}.toList()..sort();

enum ReminderProblem { startAfterEnd, noTimes, noExercises, tooManyTimes }

/// Why [reminder] cannot be saved or enabled, or null if it can. [others] may
/// include the reminder itself (matched by id); it is ignored there. The 64
/// limit counts [reminder] as enabled.
ReminderProblem? reminderProblem(Reminder reminder, Iterable<Reminder> others) {
  if (reminder.type == ReminderType.interval &&
      reminder.startMinute > reminder.endMinute) {
    return ReminderProblem.startAfterEnd;
  }
  if (reminder.fireTimes.isEmpty) return ReminderProblem.noTimes;
  if (reminder.scope == ReminderScope.chosen && reminder.itemIds.isEmpty) {
    return ReminderProblem.noExercises;
  }
  final count = distinctTimes([
    for (final r in others)
      if (reminder.id == null || r.id != reminder.id) r,
    reminder.copyWith(enabled: true),
  ]).length;
  return count > maxPending ? ReminderProblem.tooManyTimes : null;
}

/// The next enabled reminder strictly after [now], else tomorrow's first.
({int minute, Reminder reminder})? nextReminder(
  Iterable<Reminder> reminders,
  DateTime now,
) {
  final all = [
    for (final r in reminders)
      if (r.enabled)
        for (final minute in r.fireTimes) (minute: minute, reminder: r),
  ]..sort((a, b) => a.minute.compareTo(b.minute));
  final current = minuteOfDay(now);
  return all.where((x) => x.minute > current).firstOrNull ?? all.firstOrNull;
}

/// How many items the next session takes. [perSession] 0 means Auto, which
/// spreads [left] over this session and the [later] reminder times today.
int sessionSize({
  required int left,
  required int later,
  required int perSession,
}) => min(left, perSession > 0 ? perSession : (left / (later + 1)).ceil());

/// The first items of [routine] (in order) not in [doneIds].
List<RoutineItem> nextUp({
  required List<RoutineItem> routine,
  required Set<int> doneIds,
  required Iterable<Reminder> reminders,
  required int perSession,
  required DateTime now,
}) {
  final left = [
    for (final item in routine)
      if (!doneIds.contains(item.id)) item,
  ];
  final current = minuteOfDay(now);
  final later = distinctTimes(reminders).where((m) => m > current).length;
  return left
      .take(
        sessionSize(left: left.length, later: later, perSession: perSession),
      )
      .toList();
}
