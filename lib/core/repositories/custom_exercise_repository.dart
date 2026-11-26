import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../clock.dart';
import '../db/database.dart';
import '../models/exercise.dart';
import 'routine_repository.dart';

const _photoFolder = 'custom_photos';

class CustomExerciseRepository {
  CustomExerciseRepository(this._db, this._documents, this._clock);

  final AppDatabase _db;
  final Directory _documents;
  final Clock _clock;

  SimpleSelectStatement<$CustomExercisesTable, CustomExercise> get _newest =>
      _db.select(_db.customExercises)..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.rowId),
      ]);

  Exercise _exercise(CustomExercise row) =>
      Exercise.fromJson({...row.toJson(), 'isCustom': true});

  /// Custom exercises, newest first.
  Stream<List<Exercise>> watchAll() =>
      _newest.watch().map((rows) => rows.map(_exercise).toList());

  Future<List<Exercise>> getAll() async =>
      (await _newest.get()).map(_exercise).toList();

  /// Creates an exercise. The photo at [photoSource] (e.g. an image picker
  /// result) is copied into the documents folder.
  Future<Exercise> add({
    required String name,
    String notes = '',
    String? photoSource,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'is empty');
    final now = _clock();
    final id =
        'custom-${now.microsecondsSinceEpoch.toRadixString(36)}-'
        '${Random().nextInt(1 << 32).toRadixString(36)}';
    String? photoPath;
    if (photoSource != null) {
      final extension = p.extension(photoSource).toLowerCase();
      photoPath = p.join(
        _photoFolder,
        '$id${extension.isEmpty ? '.jpg' : extension}',
      );
      await Directory(p.join(_documents.path, _photoFolder))
          .create(recursive: true);
      await File(photoSource).copy(p.join(_documents.path, photoPath));
    }
    final row = await _db
        .into(_db.customExercises)
        .insertReturning(
          CustomExercisesCompanion.insert(
            id: id,
            name: trimmed,
            notes: Value(notes.trim()),
            photoPath: Value(photoPath),
            createdAt: now.millisecondsSinceEpoch,
          ),
        );
    return _exercise(row);
  }

  /// Deletes the exercise, its routine items (with reminder cleanup) and photo.
  Future<void> delete(String id) async {
    final row = await (_db.select(
      _db.customExercises,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await _db.transaction(() async {
      await RoutineRepository(_db).deleteExercise(id);
      await (_db.delete(
        _db.customExercises,
      )..where((t) => t.id.equals(id))).go();
    });
    final photoPath = row.photoPath;
    if (photoPath != null) {
      final photo = File(p.join(_documents.path, photoPath));
      if (await photo.exists()) await photo.delete();
    }
  }
}
