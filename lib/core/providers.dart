import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';
import 'db/database.dart';
import 'exercise_library.dart';
import 'models/exercise.dart';
import 'models/reminder.dart';
import 'repositories/custom_exercise_repository.dart';
import 'repositories/reminder_repository.dart';
import 'repositories/routine_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/settings_repository.dart';
import 'schedule.dart';

export 'clock.dart';
export 'db/database.dart';
export 'models/exercise.dart';
export 'models/reminder.dart';
export 'models/routine_values.dart';
export 'repositories/custom_exercise_repository.dart';
export 'repositories/reminder_repository.dart';
export 'repositories/routine_repository.dart';
export 'repositories/session_repository.dart';
export 'repositories/settings_repository.dart';
export 'schedule.dart';

final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Overridden in `main` (and in tests).
final documentsDirectoryProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('documentsDirectoryProvider not set'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'limbloop'));
  ref.onDispose(db.close);
  return db;
});

// Repositories

final routineRepositoryProvider = Provider(
  (ref) => RoutineRepository(ref.watch(databaseProvider)),
);

final reminderRepositoryProvider = Provider(
  (ref) => ReminderRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider(
  (ref) =>
      SessionRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final customExerciseRepositoryProvider = Provider(
  (ref) => CustomExerciseRepository(
    ref.watch(databaseProvider),
    ref.watch(documentsDirectoryProvider),
    ref.watch(clockProvider),
  ),
);

// Data for the UI

final bundledExercisesProvider = FutureProvider<List<Exercise>>(
  (ref) => loadBundledExercises(rootBundle),
);

final customExercisesProvider = StreamProvider<List<Exercise>>(
  (ref) => ref.watch(customExerciseRepositoryProvider).watchAll(),
);

/// Custom exercises (newest first), then the bundled ones.
final exercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final custom = ref.watch(customExercisesProvider);
  final bundled = ref.watch(bundledExercisesProvider);
  for (final part in [custom, bundled]) {
    if (part.hasError && !part.hasValue) {
      return AsyncError(part.error!, part.stackTrace!);
    }
  }
  if (!custom.hasValue || !bundled.hasValue) return const AsyncLoading();
  return AsyncData([...custom.requireValue, ...bundled.requireValue]);
});

/// Lookup by id; empty while loading.
final exerciseMapProvider = Provider<Map<String, Exercise>>(
  (ref) => {
    for (final e in ref.watch(exercisesProvider).value ?? <Exercise>[]) e.id: e,
  },
);

final routineProvider = StreamProvider<List<RoutineItem>>(
  (ref) => ref.watch(routineRepositoryProvider).watchAll(),
);

final remindersProvider = StreamProvider<List<Reminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAll(),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Today's local date. The app shell refreshes it at midnight and on resume.
final todayProvider = Provider<String>(
  (ref) => localDate(ref.watch(clockProvider)()),
);

final todaySessionsProvider = StreamProvider<List<SessionRecord>>(
  (ref) =>
      ref.watch(sessionRepositoryProvider).watchDay(ref.watch(todayProvider)),
);

/// Current routine items completed today.
final doneTodayProvider = StreamProvider<Set<int>>(
  (ref) => ref
      .watch(sessionRepositoryProvider)
      .watchDoneIds(ref.watch(todayProvider)),
);

/// Next-up items for display; null while loading. It depends on the time of day,
/// so invalidate it when the clock matters. To start a session use
/// `SessionRepository.loadNextUp` instead.
final nextUpProvider = Provider<List<RoutineItem>?>((ref) {
  final routine = ref.watch(routineProvider).value;
  final done = ref.watch(doneTodayProvider).value;
  final reminders = ref.watch(remindersProvider).value;
  final settings = ref.watch(settingsProvider).value;
  if (routine == null ||
      done == null ||
      reminders == null ||
      settings == null) {
    return null;
  }
  return nextUp(
    routine: routine,
    doneIds: done,
    reminders: reminders,
    perSession: settings.perSession,
    now: ref.watch(clockProvider)(),
  );
});
