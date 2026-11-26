import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/app/navigation.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/notification_gateway.dart';
import 'package:limbloop/features/reminders/reminder_scheduler.dart';
import 'package:limbloop/features/session/session_player_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../support/test_support.dart';
import 'support.dart';

/// Records the items of every player opened, without building the player.
class _Sessions extends NavigatorObserver {
  final opened = <List<int>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! MaterialPageRoute || previousRoute == null) return;
    final screen = route.builder(navigator!.context);
    if (screen is SessionPlayerScreen) opened.add(screen.itemIds);
  }
}

void main() {
  late AppDatabase db;
  late FakeGateway gateway;
  late TestClock clock;
  late ProviderContainer container;

  setUp(() {
    db = testDatabase();
    gateway = FakeGateway();
    clock = TestClock(DateTime.utc(2026, 3, 10, 12));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock.call),
        notificationGatewayProvider.overrideWithValue(gateway),
      ],
    );
  });

  Future<List<int>> addItems(int count) async => [
    for (var i = 0; i < count; i++) (await RoutineRepository(db).add('e$i')).id,
  ];

  Future<int> addReminder(
    ReminderScope scope, {
    Set<int> items = const {},
    List<int> times = const [900],
  }) =>
      ReminderRepository(db)
          .save(Reminder(scope: scope, itemIds: items, times: times));

  group('reschedule', () {
    tearDown(() async {
      container.dispose();
      await db.close();
    });

    ReminderScheduler scheduler() => container.read(reminderSchedulerProvider);

    test('replaces pending, merging coinciding times', () async {
      await addItems(1);
      final a = await addReminder(ReminderScope.nextUp);
      final b = await addReminder(ReminderScope.all);
      await scheduler().init();
      await Future.wait([scheduler().reschedule(), scheduler().reschedule()]);

      expect(gateway.pending, hasLength(64));
      expect(gateway.pending.values.first.payload, '$a,$b');
    });

    test('drops the rest of today once all is done', () async {
      final items = await addItems(2);
      await addReminder(ReminderScope.nextUp);
      await scheduler().init();
      int firstDay() => gateway.pending.values.first.when.day;

      await SessionRepository(db, clock.call).record([items.first]);
      await scheduler().reschedule();
      expect(firstDay(), 10);

      await SessionRepository(db, clock.call).record([items.last]);
      await scheduler().reschedule();
      expect(firstDay(), 11);
      expect(gateway.pending, hasLength(64));
    });

    test('re-reads the time zone each time', () async {
      await addItems(1);
      await addReminder(ReminderScope.all);
      await scheduler().init();
      await scheduler().reschedule();
      expect(gateway.pending.values.first.when.location.name, 'UTC');

      gateway.zone = 'Asia/Calcutta'; // An old alias Android still reports.
      await scheduler().reschedule();
      final first = gateway.pending.values.first.when;
      expect(first.location.name, 'Asia/Calcutta');
      expect((first.hour, first.minute), (15, 0));
    });

    test('clears pending when the routine is empty', () async {
      final items = await addItems(1);
      await addReminder(ReminderScope.all);
      await scheduler().init();
      await scheduler().reschedule();
      await RoutineRepository(db).delete(items.single);
      await scheduler().reschedule();
      expect(gateway.pending, isEmpty);
    });

    test('does nothing without a gateway', () async {
      final plain = ProviderContainer();
      addTearDown(plain.dispose);
      await plain.read(reminderSchedulerProvider).init();
      await plain.read(reminderSchedulerProvider).reschedule();
    });
  });

  group('tap', () {
    late _Sessions sessions;

    setUp(() => sessions = _Sessions());

    Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [sessions],
          home: const SizedBox(),
        ),
      ),
    );

    Future<void> finish(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    }

    /// Returns the items opened by tapping, or null if no session started.
    Future<List<int>?> tap(WidgetTester tester, String payload) async {
      sessions.opened.clear();
      gateway.onTap!(payload);
      for (var i = 0; i < 20; i++) {
        await tester.idle();
      }
      return sessions.opened.isEmpty ? null : sessions.opened.single;
    }

    testWidgets('cold start opens the session once', (tester) async {
      final items = await addItems(2);
      final id = await addReminder(ReminderScope.all);
      gateway.launchPayload = '$id';
      await pumpApp(tester);
      final scheduler = container.read(reminderSchedulerProvider);
      await scheduler.init();
      await scheduler.init();
      expect(sessions.opened, [items]);
      await finish(tester);
    });

    testWidgets('normal start opens nothing', (tester) async {
      await addItems(1);
      await pumpApp(tester);
      await container.read(reminderSchedulerProvider).init();
      expect(sessions.opened, isEmpty);
      await finish(tester);
    });

    testWidgets('next up is resolved when tapped', (tester) async {
      final items = await addItems(3);
      final id = await addReminder(ReminderScope.nextUp);
      await pumpApp(tester);
      await container.read(reminderSchedulerProvider).init();
      // No later reminder today at 16:00, so Auto takes everything left.
      clock.now = DateTime.utc(2026, 3, 10, 16);
      final record = SessionRepository(db, clock.call).record;

      await record([items[0]]);
      expect(await tap(tester, '$id'), [items[1], items[2]]);

      await record([items[1], items[2]]);
      expect(await tap(tester, '$id'), isNull);
      await finish(tester);
    });

    testWidgets('merged scopes use current data', (tester) async {
      final items = await addItems(4);
      await SettingsRepository(db).setPerSession(1);
      final next = await addReminder(ReminderScope.nextUp);
      final chosen = await addReminder(ReminderScope.chosen, items: {items[3]});
      final all = await addReminder(ReminderScope.all);
      await pumpApp(tester);
      await container.read(reminderSchedulerProvider).init();

      expect(await tap(tester, '$next,$chosen'), [items[0], items[3]]);
      expect(await tap(tester, '$next,$chosen,$all'), items);

      // The subset is edited after the notification was scheduled.
      await ReminderRepository(db).save(
        Reminder(
          id: chosen,
          scope: ReminderScope.chosen,
          itemIds: {items[2], items[1]},
        ),
      );
      expect(await tap(tester, '$chosen'), [items[1], items[2]]);

      // All done: next up adds nothing, the chosen subset still plays.
      await SessionRepository(db, clock.call).record(items);
      expect(await tap(tester, '$next,$chosen'), [items[1], items[2]]);

      // A deleted reminder falls back to next up.
      await SessionRepository(db, clock.call).record(items);
      clock.now = DateTime.utc(2026, 3, 11, 12);
      await ReminderRepository(db).delete(all);
      expect(await tap(tester, '$all'), [items[0]]);
      await finish(tester);
    });
  });
}
