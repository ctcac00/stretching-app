import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';
import 'package:path/path.dart' as p;

import '../support/test_support.dart';

void main() {
  late AppDatabase db;
  late Directory documents;
  late TestClock clock;
  late RoutineRepository routine;
  late ReminderRepository reminders;
  late SessionRepository sessions;
  late SettingsRepository settings;
  late CustomExerciseRepository custom;

  setUp(() {
    db = testDatabase();
    documents = Directory.systemTemp.createTempSync('limbloop');
    clock = TestClock(DateTime(2026, 11, 26, 10, 30));
    routine = RoutineRepository(db);
    reminders = ReminderRepository(db);
    sessions = SessionRepository(db, clock.call);
    settings = SettingsRepository(db);
    custom = CustomExerciseRepository(db, documents, clock.call);
  });

  tearDown(() async {
    await db.close();
    documents.deleteSync(recursive: true);
  });

  Future<List<int>> addItems(int count) async => [
    for (var i = 0; i < count; i++) (await routine.add('e$i')).id,
  ];

  Future<List<int>> routineIds() async => [
    for (final item in await routine.getAll()) item.id,
  ];

  Reminder chosen(Set<int> ids) =>
      Reminder(scope: ReminderScope.chosen, itemIds: ids);

  Matcher refused(ReminderProblem problem) => throwsA(
    isA<ReminderException>().having((e) => e.problem, 'problem', problem),
  );

  group('routine', () {
    test('add uses defaults, appends and allows duplicates', () async {
      final first = await routine.add('a');
      final second = await routine.add('a', mode: ExerciseMode.reps);

      expect(first.mode, ExerciseMode.time);
      expect(first.value, 60);
      expect(first.sides, Sides.single);
      expect(second.value, 10);
      expect(await routineIds(), [first.id, second.id]);
    });

    test('update saves and clamps values', () async {
      final item = await routine.add('a');
      await routine.update(item.copyWith(value: 9000, sides: Sides.leftRight));

      final saved = (await routine.get(item.id))!;
      expect(saved.value, 600);
      expect(saved.sides, Sides.leftRight);

      await routine.update(saved.copyWith(value: 1));
      expect((await routine.get(item.id))!.value, 5);
    });

    test('reorder changes order and the stream follows', () async {
      final [a, b, c] = await addItems(3);
      final stream = routine.watchAll().map(
        (items) => [for (final i in items) i.id],
      );
      final done = expectLater(stream, emitsThrough([c, a, b]));

      await routine.reorder([c, a, b]);
      await done;
      final d = (await routine.add('d')).id;
      expect(await routineIds(), [c, a, b, d]);
    });

    test('delete removes the item and never reuses its id', () async {
      final [a, b] = await addItems(2);
      await routine.delete(b);
      final c = (await routine.add('c')).id;

      expect(await routineIds(), [a, c]);
      expect(c, greaterThan(b));
    });
  });

  group('reminders', () {
    test('saves, updates and deletes with the subset', () async {
      final [a, b] = await addItems(2);
      final id = await reminders.save(chosen({a, b, 999}));
      var saved = (await reminders.getAll()).single;
      expect(saved.itemIds, {a, b});

      await reminders.save(
        saved.copyWith(scope: ReminderScope.all, times: [900, 600, 900]),
      );
      saved = (await reminders.getAll()).single;
      expect(saved.id, id);
      expect(saved.itemIds, isEmpty);
      expect(saved.times, [600, 900]);

      await reminders.delete(id);
      expect(await reminders.getAll(), isEmpty);
      expect(await db.select(db.reminderItems).get(), isEmpty);
    });

    test(
      'deleting routine items cleans subsets and disables empty ones',
      () async {
        final [a, b] = await addItems(2);
        final both = await reminders.save(chosen({a, b}));
        final onlyA = await reminders.save(chosen({a}));
        final next = await reminders.save(const Reminder());
        Future<Map<int, Reminder>> byId() async => {
          for (final r in await reminders.getAll()) r.id!: r,
        };
        final stream = expectLater(
          reminders.watchAll(),
          emitsThrough(
            predicate<List<Reminder>>(
              (all) => all.any((r) => r.id == onlyA && !r.enabled),
            ),
          ),
        );

        await routine.delete(a);
        await stream;

        var all = await byId();
        expect(all[both]!.itemIds, {b});
        expect(all[both]!.enabled, isTrue);
        expect(all[onlyA]!.itemIds, isEmpty);
        expect(all[onlyA]!.enabled, isFalse);
        expect(all[next]!.enabled, isTrue);
        await expectLater(
          reminders.setEnabled(onlyA, true),
          refused(ReminderProblem.noExercises),
        );

        await routine.delete(b);
        all = await byId();
        expect(all[both]!.enabled, isFalse);
        expect(all[next]!.enabled, isTrue);
      },
    );

    test('refuses unsaveable reminders', () async {
      await expectLater(
        reminders.save(const Reminder(times: [])),
        refused(ReminderProblem.noTimes),
      );
      await expectLater(
        reminders.save(
          const Reminder(
            type: ReminderType.interval,
            startMinute: 600,
            endMinute: 540,
          ),
        ),
        refused(ReminderProblem.startAfterEnd),
      );
      await expectLater(
        reminders.save(chosen({})),
        refused(ReminderProblem.noExercises),
      );
      expect(await reminders.getAll(), isEmpty);
    });

    test('limits distinct times to 64', () async {
      final id = await reminders.save(
        Reminder(times: [for (var m = 0; m < 64; m++) m]),
      );
      await reminders.save(const Reminder(times: [0, 63]));
      await expectLater(
        reminders.save(const Reminder(times: [100])),
        refused(ReminderProblem.tooManyTimes),
      );
      // Editing a reminder does not count its old times.
      final first = (await reminders.getAll()).first;
      await reminders.save(
        first.copyWith(times: [for (var m = 2; m < 63; m++) m]),
      );
      await reminders.setEnabled(id, false);
      await reminders.save(
        Reminder(times: [for (var m = 100; m < 162; m++) m]),
      );
      await addItems(1);
      await expectLater(
        reminders.setEnabled(id, true),
        refused(ReminderProblem.tooManyTimes),
      );
    });

    test('cannot enable with an empty routine', () async {
      final id = await reminders.save(const Reminder(enabled: false));
      await expectLater(
        reminders.setEnabled(id, true),
        refused(ReminderProblem.noExercises),
      );
      await addItems(1);
      await reminders.setEnabled(id, true);
      expect((await reminders.getAll()).single.enabled, isTrue);
    });
  });

  group('custom exercises', () {
    test('add copies the photo and stores a relative path', () async {
      final source = File(p.join(documents.path, 'picked.PNG'))
        ..writeAsStringSync('image');

      final exercise = await custom.add(
        name: '  Neck roll ',
        notes: 'slowly',
        photoSource: source.path,
      );

      expect(exercise.name, 'Neck roll');
      expect(exercise.isCustom, isTrue);
      expect(exercise.imageCount, 1);
      expect(p.isRelative(exercise.photoPath!), isTrue);
      expect(exercise.photoPath, endsWith('.png'));
      expect(
        File(p.join(documents.path, exercise.photoPath)).readAsStringSync(),
        'image',
      );
      expect((await custom.getAll()).single.notes, 'slowly');
    });

    test(
      'delete removes routine items, empties subsets and the photo',
      () async {
        final source = File(p.join(documents.path, 'picked.jpg'))
          ..writeAsStringSync('image');
        final exercise = await custom.add(name: 'x', photoSource: source.path);
        final a = (await routine.add(exercise.id)).id;
        await routine.add(exercise.id);
        final other = (await routine.add('bundled')).id;
        await reminders.save(chosen({a}));

        await custom.delete(exercise.id);

        expect(await custom.getAll(), isEmpty);
        expect(await routineIds(), [other]);
        expect((await reminders.getAll()).single.enabled, isFalse);
        expect(
          File(p.join(documents.path, exercise.photoPath)).existsSync(),
          isFalse,
        );
      },
    );

    test('newest first', () async {
      await custom.add(name: 'old');
      clock.now = clock.now.add(const Duration(minutes: 1));
      await custom.add(name: 'new');

      expect([for (final e in await custom.getAll()) e.name], ['new', 'old']);
    });
  });

  group('sessions', () {
    test('mark routine done records every item for the local date', () async {
      final ids = await addItems(3);

      await sessions.markRoutineDone();

      expect(await sessions.getDoneIds('2026-11-26'), ids.toSet());
      final session = (await sessions.getDay('2026-11-26')).single;
      expect(session.minute, 10 * 60 + 30);
      expect(session.itemIds, ids.toSet());
      expect(await sessions.loadNextUp(), isEmpty);
    });

    test('nothing is recorded for no items', () async {
      expect(await sessions.record([]), isNull);
      expect(await sessions.markRoutineDone(), isNull);
      expect(await db.select(db.sessions).get(), isEmpty);
    });

    test('a new local day starts undone', () async {
      final [a, b] = await addItems(2);
      clock.now = DateTime(2026, 11, 26, 23, 59);
      await sessions.record([a]);
      clock.now = DateTime(2026, 11, 27, 0, 1);
      await sessions.record([b]);

      expect(await sessions.getDoneIds('2026-11-26'), {a});
      expect(await sessions.getDoneIds('2026-11-27'), {b});
      expect([for (final i in await sessions.loadNextUp()) i.id], [a]);
    });

    test('removed items leave history but not completion', () async {
      final [a, b] = await addItems(2);
      final stream = expectLater(
        sessions.watchDoneIds('2026-11-26'),
        emitsThrough(equals({b})),
      );
      await sessions.record([a, b]);
      await routine.delete(a);
      await stream;

      expect((await sessions.getDay('2026-11-26')).single.itemIds, {a, b});
    });
  });

  test('settings have defaults and persist', () async {
    final initial = await settings.get();
    expect(initial.perSession, 0);
    expect(initial.sound, isTrue);
    expect(initial.haptics, isTrue);
    expect(initial.theme, ThemePreference.auto);

    await settings.setPerSession(2);
    await settings.setSound(false);
    await settings.setHaptics(false);
    await settings.setTheme(ThemePreference.dark);

    final saved = await settings.get();
    expect(saved.perSession, 2);
    expect(saved.sound, isFalse);
    expect(saved.haptics, isFalse);
    expect(saved.theme, ThemePreference.dark);
  });
}
