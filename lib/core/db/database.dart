// No Flutter imports here: pure Dart logic uses the generated row classes.
import 'package:drift/drift.dart';

import '../models/reminder.dart';
import '../models/routine_values.dart';

part 'database.g.dart';

class CustomExercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Relative to the app documents folder.
  TextColumn get photoPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoutineItem')
class RoutineItems extends Table {
  /// AUTOINCREMENT: ids are never reused, so session history stays unambiguous.
  IntColumn get id => integer().autoIncrement()();
  IntColumn get position => integer()();

  /// A bundled or custom exercise id.
  TextColumn get exerciseId => text()();
  TextColumn get mode => textEnum<ExerciseMode>()();

  /// Seconds (per side) or reps, depending on [mode].
  IntColumn get value => integer()();
  TextColumn get sides => textEnum<Sides>()();
}

class MinutesConverter extends TypeConverter<List<int>, String> {
  const MinutesConverter();

  @override
  List<int> fromSql(String fromDb) =>
      fromDb.isEmpty ? [] : fromDb.split(',').map(int.parse).toList();

  @override
  String toSql(List<int> value) => value.join(',');
}

@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<ReminderType>()();
  IntColumn get intervalMinutes => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get times => text().map(const MinutesConverter())();
  TextColumn get scope => textEnum<ReminderScope>()();
  BoolColumn get enabled => boolean()();
}

@DataClassName('ReminderItemRow')
class ReminderItems extends Table {
  IntColumn get reminderId =>
      integer().references(Reminders, #id, onDelete: KeyAction.cascade)();
  IntColumn get routineItemId =>
      integer().references(RoutineItems, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {reminderId, routineItemId};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local calendar date, `yyyy-MM-dd`.
  TextColumn get date => text()();

  /// Local time, minutes since midnight.
  IntColumn get minute => integer()();
}

@DataClassName('SessionItemRow')
class SessionItems extends Table {
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();

  /// Deliberately not a foreign key: history outlives removed routine items.
  IntColumn get routineItemId => integer()();

  @override
  Set<Column> get primaryKey => {sessionId, routineItemId};
}

enum ThemePreference { auto, light, dark }

/// A single row with id 0, created with the database.
@DataClassName('AppSettings')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// 0 means Auto, otherwise 1 to 3.
  IntColumn get perSession => integer().withDefault(const Constant(0))();
  BoolColumn get sound => boolean().withDefault(const Constant(true))();
  BoolColumn get haptics => boolean().withDefault(const Constant(true))();
  TextColumn get theme => textEnum<ThemePreference>().withDefault(
    Constant(ThemePreference.auto.name),
  )();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    CustomExercises,
    RoutineItems,
    Reminders,
    ReminderItems,
    Sessions,
    SessionItems,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(settings).insert(const SettingsCompanion());
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
