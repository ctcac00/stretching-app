import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/app/app_events.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/reminder_scheduler.dart';
import 'package:limbloop/features/session/session_launcher.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Stands in for the notification service handling the launch notification.
class _LaunchedByNotification extends ReminderScheduler {
  _LaunchedByNotification(super.ref);

  @override
  Future<void> init() => openNextUpSession();

  @override
  Future<void> reschedule() async {}
}

void main() {
  const second = Duration(seconds: 1);
  late Harness h;

  setUp(() => h = Harness(DateTime(2026, 11, 26, 9)));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('counts down, switches sides and records on finish', (
    tester,
  ) async {
    await h.pump(tester);
    final a = await h.routine.add('a', value: 30, sides: Sides.leftRight);
    openSession([a.id]);
    await tester.pumpAndSettle();
    expect(find.text('Get ready: left side'), findsOne);
    expect(find.text('5'), findsOne);
    expect(h.device.awake, [true]);

    await h.advance(tester, second * 2);
    expect(find.text('3'), findsOne);
    await h.advance(tester, second * 3);
    expect(find.text('Left side'), findsOne);
    expect(find.text('30'), findsOne);
    await h.advance(tester, second * 30);
    expect(find.text('Switch to right side'), findsOne);
    await h.advance(tester, second * 5);
    expect(find.text('Right side'), findsOne);
    expect(await h.recorded(), isEmpty);
    await h.advance(tester, second * 30);
    expect(find.text('1 of 1 exercises completed.'), findsOne);
    expect(h.device.awake, [true, false]);
    expect((h.device.sounds, h.device.haptics), (4, 4));

    await tap(tester, find.text('Back to today'));
    expect(find.text('home'), findsOne);
    expect(await h.recorded(), [
      {a.id},
    ]);
    expect(h.device.awake, [true, false]);
    await h.close(tester);
  });

  testWidgets('close records completed items; sound can be off', (
    tester,
  ) async {
    await h.pump(tester);
    await h.settings.setSound(false);
    final a = await h.routine.add('a');
    final b = await h.routine.add('b', mode: ExerciseMode.reps);
    openSession([a.id, b.id]);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Start now'));
    await tap(tester, find.text('Done'));
    expect(find.text('Beta'), findsOne);
    await tap(tester, find.byType(CloseButton));
    expect(await h.recorded(), [
      {a.id},
    ]);
    expect(h.device.sounds, 0);
    expect(h.device.haptics, 2);
    await h.close(tester);
  });

  testWidgets('back navigation records too; skipped items do not count', (
    tester,
  ) async {
    await h.pump(tester);
    final a = await h.routine.add('a');
    final b = await h.routine.add('b');
    openSession([a.id, b.id]);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Skip'));
    await tap(tester, find.text('Start now'));
    await tap(tester, find.text('Done'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(await h.recorded(), [
      {b.id},
    ]);
    await h.close(tester);
  });

  testWidgets('backgrounded: no ticks or cues, one phase on return', (
    tester,
  ) async {
    await h.pump(tester);
    final a = await h.routine.add('a', value: 30);
    openSession([a.id]);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Start now'));
    final cues = h.device.sounds;

    void lifecycle(List<AppLifecycleState> states) =>
        states.forEach(tester.binding.handleAppLifecycleStateChanged);
    lifecycle([
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    h.clock.now = h.clock.now.add(const Duration(minutes: 5));
    await tester.pump(second);
    expect(h.device.sounds, cues);
    expect(await h.recorded(), isEmpty);

    lifecycle([
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 exercises completed.'), findsOne);
    expect(h.device.sounds, cues + 1);
    await h.close(tester);
  });

  testWidgets('replacing a running session records it exactly once', (
    tester,
  ) async {
    await h.pump(tester);
    final a = await h.routine.add('a');
    final b = await h.routine.add('b');
    openSession([a.id, b.id]);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Start now'));
    await tap(tester, find.text('Done'));
    openSession([b.id]);
    await tester.pumpAndSettle();
    expect(find.text('1 of 1'), findsOne);
    expect(await h.recorded(), [
      {a.id},
    ]);
    // The new session still holds the screen awake.
    expect(h.device.awake, [true, false, true]);
    await h.close(tester);
    expect(h.device.awake.last, false);
  });

  testWidgets('next up does not repeat what the running session completed', (
    tester,
  ) async {
    await h.pump(tester);
    await h.settings.setPerSession(1);
    final a = await h.routine.add('a');
    await h.routine.add('b');
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOne);
    await tap(tester, find.text('Start now'));
    // Completed but not yet recorded: a second item keeps the session open.
    openSession([a.id, a.id + 1]);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Start now'));
    await tap(tester, find.text('Done'));
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOne);
    expect(find.text('1 of 1'), findsOne);

    // Nothing left: the running session closes and none starts.
    await tap(tester, find.text('Start now'));
    await h.sessions.markRoutineDone();
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOne);
    await h.close(tester);
  });

  testWidgets('all done: next up opens nothing until the next day', (
    tester,
  ) async {
    await h.pump(tester);
    await h.routine.add('a');
    await h.sessions.markRoutineDone();
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOne);

    h.clock.now = DateTime(2026, 11, 27, 0, 0, 1);
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOne);
    await h.close(tester);
  });

  testWidgets('next up takes the auto count at the time it starts', (
    tester,
  ) async {
    await h.pump(tester);
    for (final id in ['a', 'b', 'a', 'b']) {
      await h.routine.add(id);
    }
    await h.reminders.save(const Reminder(times: [12 * 60]));
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOne);

    h.clock.now = DateTime(2026, 11, 26, 12);
    await openNextUpSession();
    await tester.pumpAndSettle();
    expect(find.text('1 of 4'), findsOne);
    await h.close(tester);
  });

  testWidgets('notification tap from cold start opens next up', (tester) async {
    await h.routine.add('a');
    await h.pump(
      tester,
      home: const AppEvents(child: Scaffold(body: Text('home'))),
      overrides: [
        reminderSchedulerProvider.overrideWith(_LaunchedByNotification.new),
      ],
    );
    expect(find.text('Alpha'), findsOne);
    expect(find.text('Get ready'), findsOne);
    await h.close(tester);
  });

  testWidgets('deleted items are left out and unknown exercises still play', (
    tester,
  ) async {
    await h.pump(tester);
    final gone = await h.routine.add('a');
    final unknown = await h.routine.add('nope');
    await h.routine.delete(gone.id);
    openSession([gone.id, unknown.id]);
    await tester.pumpAndSettle();
    expect(find.text('Unknown exercise'), findsOne);
    expect(find.text('1 of 1'), findsOne);

    openSession([gone.id]);
    await tester.pumpAndSettle();
    expect(
      find.text('These exercises are no longer in your routine.'),
      findsOne,
    );
    await tap(tester, find.byType(CloseButton));
    expect(await h.recorded(), isEmpty);
    await h.close(tester);
  });
}
