import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/notification_gateway.dart';
import 'package:limbloop/features/reminders/reminders_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/data/latest_all.dart';

import '../support/test_support.dart';
import 'support.dart';

void main() {
  setUpAll(initializeTimeZones);

  late AppDatabase db;
  late FakeGateway gateway;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
          bundledExercisesProvider.overrideWith((ref) async => []),
          notificationGatewayProvider.overrideWithValue(gateway),
        ],
        child: const MaterialApp(home: RemindersScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    db = testDatabase();
    gateway = FakeGateway();
  });

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  }

  testWidgets('asks permission on save and shows a notice if refused', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('0 of 64 notification slots used'), findsOne);
    expect(find.text('Notifications are off'), findsNothing);
    expect(gateway.requests, 0);

    await tester.tap(find.text('Add reminder'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Save'), 200);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(gateway.requests, 1);
    expect(find.text('1 of 64 notification slots used'), findsOne);
    expect(find.text('Notifications are off'), findsOne);
    expect(find.textContaining('Android Settings'), findsOne);
    await finish(tester);
  });

  testWidgets('enabling beyond 64 times is refused', (tester) async {
    final repository = ReminderRepository(db);
    await RoutineRepository(db).add('x');
    final extra = await repository.save(const Reminder(times: [1000]));
    await repository.setEnabled(extra, false);
    await repository.save(Reminder(times: [for (var i = 0; i < 64; i++) i]));
    await pumpScreen(tester);
    expect(find.text('64 of 64 notification slots used'), findsOne);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(find.text('That exceeds 64 notification slots.'), findsOne);
    expect((await repository.getAll()).first.enabled, isFalse);
    await finish(tester);
  });

  testWidgets('an empty subset cannot be saved', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Add reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Save'), 200);

    expect(find.text('This reminder has no exercises.'), findsOne);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNull,
    );
    await finish(tester);
  });
}
