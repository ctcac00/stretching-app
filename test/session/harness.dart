import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/app/navigation.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/session/session_device.dart';
import 'package:material_ui/material_ui.dart';

import '../support/test_support.dart';

class FakeDevice implements SessionDevice {
  final awake = <bool>[];
  int sounds = 0;
  int haptics = 0;

  @override
  Future<void> keepAwake(bool on) async => awake.add(on);

  @override
  Future<void> sound() async => sounds++;

  @override
  Future<void> haptic() async => haptics++;

  @override
  Future<void> dispose() async {}
}

class Harness {
  Harness(DateTime now) : clock = TestClock(now);

  final TestClock clock;
  final db = testDatabase();
  final device = FakeDevice();

  late final routine = RoutineRepository(db);
  late final reminders = ReminderRepository(db);
  late final sessions = SessionRepository(db, clock.call);
  late final settings = SettingsRepository(db);

  Future<void> pump(
    WidgetTester tester, {
    Widget home = const Scaffold(body: Text('home')),
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
          bundledExercisesProvider.overrideWith(
            (ref) => const [
              Exercise(id: 'a', name: 'Alpha'),
              Exercise(id: 'b', name: 'Beta'),
            ],
          ),
          clockProvider.overrideWithValue(clock.call),
          sessionDeviceProvider.overrideWithValue(device),
          ...overrides,
        ],
        child: MaterialApp(navigatorKey: navigatorKey, home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Moves the wall clock and lets the periodic timers see it.
  Future<void> advance(WidgetTester tester, Duration duration) async {
    clock.now = clock.now.add(duration);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<List<Set<int>>> recorded() async => [
    for (final s in await sessions.getDay(localDate(clock.now))) s.itemIds,
  ];

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  }
}
