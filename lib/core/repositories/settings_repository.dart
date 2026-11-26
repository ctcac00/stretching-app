import 'package:drift/drift.dart';

import '../db/database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSettings> watch() => _db.select(_db.settings).watchSingle();

  Future<AppSettings> get() => _db.select(_db.settings).getSingle();

  Future<void> _write(SettingsCompanion values) =>
      _db.update(_db.settings).write(values);

  /// 0 means Auto, otherwise 1 to 3.
  Future<void> setPerSession(int count) =>
      _write(SettingsCompanion(perSession: Value(count.clamp(0, 3))));

  Future<void> setSound(bool on) => _write(SettingsCompanion(sound: Value(on)));

  Future<void> setHaptics(bool on) =>
      _write(SettingsCompanion(haptics: Value(on)));

  Future<void> setTheme(ThemePreference theme) =>
      _write(SettingsCompanion(theme: Value(theme)));
}
