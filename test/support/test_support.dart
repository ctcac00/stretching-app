import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:limbloop/core/db/database.dart';

/// In-memory database. Streams close synchronously, so widget tests do not end
/// with pending timers.
AppDatabase testDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// A settable clock: pass `clock.call` wherever a `Clock` is wanted.
class TestClock {
  TestClock(this.now);

  DateTime now;

  DateTime call() => now;
}
