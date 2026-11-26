import '../../core/providers.dart';

/// "30 min", "1 h", "1.5 h".
String intervalLabel(int minutes) => minutes < 60
    ? '$minutes min'
    : '${minutes % 60 == 0 ? minutes ~/ 60 : minutes / 60} h';

String reminderTitle(Reminder r) => r.type == ReminderType.interval
    ? 'Every ${intervalLabel(r.intervalMinutes)}, '
          '${formatMinute(r.startMinute)}–${formatMinute(r.endMinute)}'
    : r.fireTimes.map(formatMinute).join(', ');

String problemText(ReminderProblem problem) => switch (problem) {
  ReminderProblem.startAfterEnd => 'The start must not be after the end.',
  ReminderProblem.noTimes => 'Add at least one time.',
  ReminderProblem.noExercises => 'This reminder has no exercises.',
  ReminderProblem.tooManyTimes =>
    'That exceeds $maxPending notification slots.',
};
