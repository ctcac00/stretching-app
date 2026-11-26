/// Which one-off notifications to have pending. Pure Dart: no Flutter imports.
library;

import 'package:timezone/timezone.dart';

import '../../core/models/reminder.dart';
import '../../core/schedule.dart';

/// One notification: an instant, and the reminders that share it.
typedef Occurrence = ({TZDateTime when, Set<int> reminderIds});

/// The next [maxPending] reminder instants strictly after [now], soonest first,
/// one per distinct time per day in [location]. Nothing if [routineIds] is empty.
/// Today is left out once every routine item is in [doneIds].
List<Occurrence> upcomingOccurrences({
  required Iterable<Reminder> reminders,
  required Set<int> routineIds,
  required Set<int> doneIds,
  required Location location,
  required DateTime now,
}) {
  final times = distinctTimes(reminders);
  if (routineIds.isEmpty || times.isEmpty) return [];
  final today = TZDateTime.from(now, location);
  final result = <Occurrence>[];
  var day = doneIds.containsAll(routineIds) ? 1 : 0;
  for (; result.length < maxPending; day++) {
    // Keyed by instant: a time skipped by DST can land on another one.
    final instants = <TZDateTime, Set<int>>{};
    for (final minute in times) {
      // Calendar arithmetic, so days of 23 or 25 hours stay correct.
      final when = TZDateTime(
        location,
        today.year,
        today.month,
        today.day + day,
        minute ~/ 60,
        minute % 60,
      );
      if (!when.isAfter(now)) continue;
      instants.putIfAbsent(when, () => {}).addAll([
        for (final r in reminders)
          if (r.enabled && r.fireTimes.contains(minute)) r.id!,
      ]);
    }
    for (final when in instants.keys.toList()..sort()) {
      result.add((when: when, reminderIds: instants[when]!));
    }
  }
  return result.take(maxPending).toList();
}

/// A notification carries only reminder ids, so that scopes and next-up items
/// are read from current data when it is tapped.
String encodePayload(Set<int> reminderIds) =>
    (reminderIds.toList()..sort()).join(',');

Set<int> decodePayload(String? payload) => {
  for (final part in (payload ?? '').split(',')) ?int.tryParse(part),
};
