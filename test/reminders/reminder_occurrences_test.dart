import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/reminder_occurrences.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

void main() {
  setUpAll(initializeTimeZones);

  List<Occurrence> expand(
    List<Reminder> reminders, {
    required DateTime now,
    Location? location,
    Set<int> routine = const {1, 2},
    Set<int> done = const {},
  }) => upcomingOccurrences(
    reminders: reminders,
    routineIds: routine,
    doneIds: done,
    location: location ?? UTC,
    now: now,
  );

  String show(Occurrence o) =>
      '${o.when.day} ${formatMinute(o.when.hour * 60 + o.when.minute)}';

  final noon = DateTime.utc(2026, 3, 10, 12);

  test('chronological across days, strictly after now, one per time', () {
    final result = expand([
      const Reminder(id: 1, times: [720, 900]),
      const Reminder(id: 2, times: [540, 900]),
      const Reminder(id: 3, times: [800], enabled: false),
    ], now: noon);
    expect(result.take(5).map(show), [
      '10 15:00',
      '11 09:00',
      '11 12:00',
      '11 15:00',
      '12 09:00',
    ]);
    expect(result[0].reminderIds, {1, 2});
    expect(result[1].reminderIds, {2});
    expect(result[2].reminderIds, {1});
  });

  test('stops at 64', () {
    final one = expand([
      const Reminder(id: 1, times: [540]),
    ], now: noon);
    expect(one, hasLength(64));
    expect(one.last.when, TZDateTime(UTC, 2026, 3, 10 + 64, 9));

    final many = expand([
      Reminder(id: 1, times: [for (var i = 0; i < 64; i++) i * 20]),
    ], now: noon);
    expect(many, hasLength(64));
    expect(many.map((o) => o.when).toSet(), hasLength(64));
  });

  test('skips today only when every routine item is done', () {
    const reminders = [
      Reminder(id: 1, times: [900]),
    ];
    expect(show(expand(reminders, now: noon, done: {1}).first), '10 15:00');
    expect(
      show(expand(reminders, now: noon, done: {1, 2, 9}).first),
      '11 15:00',
    );
  });

  test('nothing without a routine or an enabled reminder', () {
    expect(expand(const [Reminder(id: 1)], now: noon, routine: {}), isEmpty);
    expect(expand(const [Reminder(id: 1, enabled: false)], now: noon), isEmpty);
    expect(expand(const [], now: noon), isEmpty);
  });

  test('days are local to the location', () {
    final tokyo = getLocation('Asia/Tokyo');
    // 20:00 UTC on the 10th is 05:00 on the 11th in Tokyo.
    final result = expand(
      const [
        Reminder(id: 1, times: [540]),
      ],
      now: DateTime.utc(2026, 3, 10, 20),
      location: tokyo,
    );
    expect(result.first.when, TZDateTime(tokyo, 2026, 3, 11, 9));
  });

  for (final (name, month, day) in [
    ('America/New_York', 3, 8),
    ('Europe/Lisbon', 3, 29),
    ('America/New_York', 11, 1),
    ('Europe/Lisbon', 10, 25),
  ]) {
    test('keeps wall-clock times across DST in $name, month $month', () {
      final location = getLocation(name);
      final result = expand(
        const [
          Reminder(id: 1, times: [540]),
        ],
        now: TZDateTime(location, 2026, month, day - 1, 8),
        location: location,
      );
      expect(result.take(3).map((o) => (o.when.day, o.when.hour)), [
        for (var i = -1; i <= 1; i++)
          (TZDateTime(location, 2026, month, day + i, 12).day, 9),
      ]);
    });
  }

  test('a time skipped by DST fires once, merged if it lands on another', () {
    final location = getLocation('America/New_York');
    final result = expand(
      const [
        Reminder(id: 1, times: [150]), // 02:30 does not exist on 8 March.
        Reminder(id: 2, times: [180, 210]),
      ],
      now: TZDateTime(location, 2026, 3, 8),
      location: location,
    );
    expect(result.take(3).map(show), ['8 03:00', '8 03:30', '9 02:30']);
    expect(result[1].reminderIds, {1, 2});
  });

  test('payload round trip tolerates junk', () {
    expect(decodePayload(encodePayload({3, 1})), {1, 3});
    expect(decodePayload(null), isEmpty);
    expect(decodePayload(''), isEmpty);
  });
}
