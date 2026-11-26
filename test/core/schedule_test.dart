import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';

void main() {
  test(
    'interval expands and includes the end only when a step lands on it',
    () {
      const every2h = Reminder(
        type: ReminderType.interval,
        startMinute: 9 * 60,
        endMinute: 18 * 60,
      );
      expect(every2h.fireTimes.map(formatMinute), [
        '09:00',
        '11:00',
        '13:00',
        '15:00',
        '17:00',
      ]);
      expect(every2h.copyWith(endMinute: 17 * 60).fireTimes.last, 17 * 60);
    },
  );

  test('scope label is singular for one chosen exercise', () {
    const one = Reminder(scope: ReminderScope.chosen, itemIds: {1});
    expect(one.scopeLabel, '1 chosen exercise');
    expect(one.copyWith(itemIds: {1, 2}).scopeLabel, '2 chosen exercises');
  });

  test('auto session size spreads what is left', () {
    expect(sessionSize(left: 5, later: 2, perSession: 0), 2);
    expect(sessionSize(left: 5, later: 0, perSession: 0), 5);
    expect(sessionSize(left: 5, later: 2, perSession: 3), 3);
    expect(sessionSize(left: 1, later: 2, perSession: 3), 1);
    expect(sessionSize(left: 0, later: 2, perSession: 0), 0);
  });

  test('next reminder wraps to tomorrow and skips disabled ones', () {
    const reminders = [
      Reminder(times: [600, 900]),
      Reminder(times: [700], enabled: false),
    ];
    expect(nextReminder(reminders, DateTime(2026, 1, 1, 10))!.minute, 900);
    expect(nextReminder(reminders, DateTime(2026, 1, 1, 16))!.minute, 600);
    expect(nextReminder(const [], DateTime(2026)), isNull);
  });

  test('next up counts distinct enabled times strictly after now', () {
    RoutineItem item(int id) => RoutineItem(
      id: id,
      position: id,
      exerciseId: 'e',
      mode: ExerciseMode.time,
      value: 60,
      sides: Sides.single,
    );
    final result = nextUp(
      routine: [for (var i = 1; i <= 5; i++) item(i)],
      doneIds: {1},
      reminders: const [
        Reminder(times: [600, 700, 800]),
        Reminder(times: [700]),
        Reminder(times: [900], enabled: false),
      ],
      perSession: 0,
      now: DateTime(2026, 1, 1, 10),
    );
    // 4 left, later = {700, 800} -> ceil(4 / 3) = 2.
    expect([for (final i in result) i.id], [2, 3]);
  });
}
