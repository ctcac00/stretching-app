// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, notes, photoPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final String id;
  final String name;
  final String notes;

  /// Relative to the app documents folder.
  final String? photoPath;
  final int createdAt;
  const CustomExercise({
    required this.id,
    required this.name,
    required this.notes,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      notes: Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory CustomExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CustomExercise copyWith({
    String? id,
    String? name,
    String? notes,
    Value<String?> photoPath = const Value.absent(),
    int? createdAt,
  }) => CustomExercise(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomExercise copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<String?> photoPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    required String id,
    required String name,
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CustomExercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? notes,
    Value<String?>? photoPath,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems
    with TableInfo<$RoutineItemsTable, RoutineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExerciseMode>($RoutineItemsTable.$convertermode);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sides, String> sides =
      GeneratedColumn<String>(
        'sides',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Sides>($RoutineItemsTable.$convertersides);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    position,
    exerciseId,
    mode,
    value,
    sides,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      mode: $RoutineItemsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      sides: $RoutineItemsTable.$convertersides.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sides'],
        )!,
      ),
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseMode, String, String> $convertermode =
      const EnumNameConverter<ExerciseMode>(ExerciseMode.values);
  static JsonTypeConverter2<Sides, String, String> $convertersides =
      const EnumNameConverter<Sides>(Sides.values);
}

class RoutineItem extends DataClass implements Insertable<RoutineItem> {
  /// AUTOINCREMENT: ids are never reused, so session history stays unambiguous.
  final int id;
  final int position;

  /// A bundled or custom exercise id.
  final String exerciseId;
  final ExerciseMode mode;

  /// Seconds (per side) or reps, depending on [mode].
  final int value;
  final Sides sides;
  const RoutineItem({
    required this.id,
    required this.position,
    required this.exerciseId,
    required this.mode,
    required this.value,
    required this.sides,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['position'] = Variable<int>(position);
    map['exercise_id'] = Variable<String>(exerciseId);
    {
      map['mode'] = Variable<String>(
        $RoutineItemsTable.$convertermode.toSql(mode),
      );
    }
    map['value'] = Variable<int>(value);
    {
      map['sides'] = Variable<String>(
        $RoutineItemsTable.$convertersides.toSql(sides),
      );
    }
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      position: Value(position),
      exerciseId: Value(exerciseId),
      mode: Value(mode),
      value: Value(value),
      sides: Value(sides),
    );
  }

  factory RoutineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItem(
      id: serializer.fromJson<int>(json['id']),
      position: serializer.fromJson<int>(json['position']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      mode: $RoutineItemsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      value: serializer.fromJson<int>(json['value']),
      sides: $RoutineItemsTable.$convertersides.fromJson(
        serializer.fromJson<String>(json['sides']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'position': serializer.toJson<int>(position),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'mode': serializer.toJson<String>(
        $RoutineItemsTable.$convertermode.toJson(mode),
      ),
      'value': serializer.toJson<int>(value),
      'sides': serializer.toJson<String>(
        $RoutineItemsTable.$convertersides.toJson(sides),
      ),
    };
  }

  RoutineItem copyWith({
    int? id,
    int? position,
    String? exerciseId,
    ExerciseMode? mode,
    int? value,
    Sides? sides,
  }) => RoutineItem(
    id: id ?? this.id,
    position: position ?? this.position,
    exerciseId: exerciseId ?? this.exerciseId,
    mode: mode ?? this.mode,
    value: value ?? this.value,
    sides: sides ?? this.sides,
  );
  RoutineItem copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItem(
      id: data.id.present ? data.id.value : this.id,
      position: data.position.present ? data.position.value : this.position,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      mode: data.mode.present ? data.mode.value : this.mode,
      value: data.value.present ? data.value.value : this.value,
      sides: data.sides.present ? data.sides.value : this.sides,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItem(')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('mode: $mode, ')
          ..write('value: $value, ')
          ..write('sides: $sides')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, position, exerciseId, mode, value, sides);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItem &&
          other.id == this.id &&
          other.position == this.position &&
          other.exerciseId == this.exerciseId &&
          other.mode == this.mode &&
          other.value == this.value &&
          other.sides == this.sides);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItem> {
  final Value<int> id;
  final Value<int> position;
  final Value<String> exerciseId;
  final Value<ExerciseMode> mode;
  final Value<int> value;
  final Value<Sides> sides;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.position = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.mode = const Value.absent(),
    this.value = const Value.absent(),
    this.sides = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    this.id = const Value.absent(),
    required int position,
    required String exerciseId,
    required ExerciseMode mode,
    required int value,
    required Sides sides,
  }) : position = Value(position),
       exerciseId = Value(exerciseId),
       mode = Value(mode),
       value = Value(value),
       sides = Value(sides);
  static Insertable<RoutineItem> custom({
    Expression<int>? id,
    Expression<int>? position,
    Expression<String>? exerciseId,
    Expression<String>? mode,
    Expression<int>? value,
    Expression<String>? sides,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (position != null) 'position': position,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (mode != null) 'mode': mode,
      if (value != null) 'value': value,
      if (sides != null) 'sides': sides,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? position,
    Value<String>? exerciseId,
    Value<ExerciseMode>? mode,
    Value<int>? value,
    Value<Sides>? sides,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      position: position ?? this.position,
      exerciseId: exerciseId ?? this.exerciseId,
      mode: mode ?? this.mode,
      value: value ?? this.value,
      sides: sides ?? this.sides,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $RoutineItemsTable.$convertermode.toSql(mode.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (sides.present) {
      map['sides'] = Variable<String>(
        $RoutineItemsTable.$convertersides.toSql(sides.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('mode: $mode, ')
          ..write('value: $value, ')
          ..write('sides: $sides')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderType>($RemindersTable.$convertertype);
  static const VerificationMeta _intervalMinutesMeta = const VerificationMeta(
    'intervalMinutes',
  );
  @override
  late final GeneratedColumn<int> intervalMinutes = GeneratedColumn<int>(
    'interval_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> times =
      GeneratedColumn<String>(
        'times',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($RemindersTable.$convertertimes);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderScope, String> scope =
      GeneratedColumn<String>(
        'scope',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderScope>($RemindersTable.$converterscope);
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    intervalMinutes,
    startMinute,
    endMinute,
    times,
    scope,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('interval_minutes')) {
      context.handle(
        _intervalMinutesMeta,
        intervalMinutes.isAcceptableOrUnknown(
          data['interval_minutes']!,
          _intervalMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalMinutesMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $RemindersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      intervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_minutes'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      times: $RemindersTable.$convertertimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}times'],
        )!,
      ),
      scope: $RemindersTable.$converterscope.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scope'],
        )!,
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderType, String, String> $convertertype =
      const EnumNameConverter<ReminderType>(ReminderType.values);
  static TypeConverter<List<int>, String> $convertertimes =
      const MinutesConverter();
  static JsonTypeConverter2<ReminderScope, String, String> $converterscope =
      const EnumNameConverter<ReminderScope>(ReminderScope.values);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final ReminderType type;
  final int intervalMinutes;
  final int startMinute;
  final int endMinute;
  final List<int> times;
  final ReminderScope scope;
  final bool enabled;
  const ReminderRow({
    required this.id,
    required this.type,
    required this.intervalMinutes,
    required this.startMinute,
    required this.endMinute,
    required this.times,
    required this.scope,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type),
      );
    }
    map['interval_minutes'] = Variable<int>(intervalMinutes);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    {
      map['times'] = Variable<String>(
        $RemindersTable.$convertertimes.toSql(times),
      );
    }
    {
      map['scope'] = Variable<String>(
        $RemindersTable.$converterscope.toSql(scope),
      );
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      type: Value(type),
      intervalMinutes: Value(intervalMinutes),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      times: Value(times),
      scope: Value(scope),
      enabled: Value(enabled),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      type: $RemindersTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      intervalMinutes: serializer.fromJson<int>(json['intervalMinutes']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      times: serializer.fromJson<List<int>>(json['times']),
      scope: $RemindersTable.$converterscope.fromJson(
        serializer.fromJson<String>(json['scope']),
      ),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $RemindersTable.$convertertype.toJson(type),
      ),
      'intervalMinutes': serializer.toJson<int>(intervalMinutes),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'times': serializer.toJson<List<int>>(times),
      'scope': serializer.toJson<String>(
        $RemindersTable.$converterscope.toJson(scope),
      ),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ReminderRow copyWith({
    int? id,
    ReminderType? type,
    int? intervalMinutes,
    int? startMinute,
    int? endMinute,
    List<int>? times,
    ReminderScope? scope,
    bool? enabled,
  }) => ReminderRow(
    id: id ?? this.id,
    type: type ?? this.type,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    times: times ?? this.times,
    scope: scope ?? this.scope,
    enabled: enabled ?? this.enabled,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      intervalMinutes: data.intervalMinutes.present
          ? data.intervalMinutes.value
          : this.intervalMinutes,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      times: data.times.present ? data.times.value : this.times,
      scope: data.scope.present ? data.scope.value : this.scope,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('times: $times, ')
          ..write('scope: $scope, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    intervalMinutes,
    startMinute,
    endMinute,
    times,
    scope,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.intervalMinutes == this.intervalMinutes &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.times == this.times &&
          other.scope == this.scope &&
          other.enabled == this.enabled);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<ReminderType> type;
  final Value<int> intervalMinutes;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<List<int>> times;
  final Value<ReminderScope> scope;
  final Value<bool> enabled;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.times = const Value.absent(),
    this.scope = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required ReminderType type,
    required int intervalMinutes,
    required int startMinute,
    required int endMinute,
    required List<int> times,
    required ReminderScope scope,
    required bool enabled,
  }) : type = Value(type),
       intervalMinutes = Value(intervalMinutes),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       times = Value(times),
       scope = Value(scope),
       enabled = Value(enabled);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? intervalMinutes,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<String>? times,
    Expression<String>? scope,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (intervalMinutes != null) 'interval_minutes': intervalMinutes,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (times != null) 'times': times,
      if (scope != null) 'scope': scope,
      if (enabled != null) 'enabled': enabled,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<ReminderType>? type,
    Value<int>? intervalMinutes,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<List<int>>? times,
    Value<ReminderScope>? scope,
    Value<bool>? enabled,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      times: times ?? this.times,
      scope: scope ?? this.scope,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type.value),
      );
    }
    if (intervalMinutes.present) {
      map['interval_minutes'] = Variable<int>(intervalMinutes.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(
        $RemindersTable.$convertertimes.toSql(times.value),
      );
    }
    if (scope.present) {
      map['scope'] = Variable<String>(
        $RemindersTable.$converterscope.toSql(scope.value),
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('times: $times, ')
          ..write('scope: $scope, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $ReminderItemsTable extends ReminderItems
    with TableInfo<$ReminderItemsTable, ReminderItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _routineItemIdMeta = const VerificationMeta(
    'routineItemId',
  );
  @override
  late final GeneratedColumn<int> routineItemId = GeneratedColumn<int>(
    'routine_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_items (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [reminderId, routineItemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('routine_item_id')) {
      context.handle(
        _routineItemIdMeta,
        routineItemId.isAcceptableOrUnknown(
          data['routine_item_id']!,
          _routineItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineItemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reminderId, routineItemId};
  @override
  ReminderItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderItemRow(
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_id'],
      )!,
      routineItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_item_id'],
      )!,
    );
  }

  @override
  $ReminderItemsTable createAlias(String alias) {
    return $ReminderItemsTable(attachedDatabase, alias);
  }
}

class ReminderItemRow extends DataClass implements Insertable<ReminderItemRow> {
  final int reminderId;
  final int routineItemId;
  const ReminderItemRow({
    required this.reminderId,
    required this.routineItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reminder_id'] = Variable<int>(reminderId);
    map['routine_item_id'] = Variable<int>(routineItemId);
    return map;
  }

  ReminderItemsCompanion toCompanion(bool nullToAbsent) {
    return ReminderItemsCompanion(
      reminderId: Value(reminderId),
      routineItemId: Value(routineItemId),
    );
  }

  factory ReminderItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderItemRow(
      reminderId: serializer.fromJson<int>(json['reminderId']),
      routineItemId: serializer.fromJson<int>(json['routineItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reminderId': serializer.toJson<int>(reminderId),
      'routineItemId': serializer.toJson<int>(routineItemId),
    };
  }

  ReminderItemRow copyWith({int? reminderId, int? routineItemId}) =>
      ReminderItemRow(
        reminderId: reminderId ?? this.reminderId,
        routineItemId: routineItemId ?? this.routineItemId,
      );
  ReminderItemRow copyWithCompanion(ReminderItemsCompanion data) {
    return ReminderItemRow(
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      routineItemId: data.routineItemId.present
          ? data.routineItemId.value
          : this.routineItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderItemRow(')
          ..write('reminderId: $reminderId, ')
          ..write('routineItemId: $routineItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(reminderId, routineItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderItemRow &&
          other.reminderId == this.reminderId &&
          other.routineItemId == this.routineItemId);
}

class ReminderItemsCompanion extends UpdateCompanion<ReminderItemRow> {
  final Value<int> reminderId;
  final Value<int> routineItemId;
  final Value<int> rowid;
  const ReminderItemsCompanion({
    this.reminderId = const Value.absent(),
    this.routineItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderItemsCompanion.insert({
    required int reminderId,
    required int routineItemId,
    this.rowid = const Value.absent(),
  }) : reminderId = Value(reminderId),
       routineItemId = Value(routineItemId);
  static Insertable<ReminderItemRow> custom({
    Expression<int>? reminderId,
    Expression<int>? routineItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reminderId != null) 'reminder_id': reminderId,
      if (routineItemId != null) 'routine_item_id': routineItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderItemsCompanion copyWith({
    Value<int>? reminderId,
    Value<int>? routineItemId,
    Value<int>? rowid,
  }) {
    return ReminderItemsCompanion(
      reminderId: reminderId ?? this.reminderId,
      routineItemId: routineItemId ?? this.routineItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (routineItemId.present) {
      map['routine_item_id'] = Variable<int>(routineItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderItemsCompanion(')
          ..write('reminderId: $reminderId, ')
          ..write('routineItemId: $routineItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, minute];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final int id;

  /// Local calendar date, `yyyy-MM-dd`.
  final String date;

  /// Local time, minutes since midnight.
  final int minute;
  const SessionRow({
    required this.id,
    required this.date,
    required this.minute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['minute'] = Variable<int>(minute);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      date: Value(date),
      minute: Value(minute),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      minute: serializer.fromJson<int>(json['minute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'minute': serializer.toJson<int>(minute),
    };
  }

  SessionRow copyWith({int? id, String? date, int? minute}) => SessionRow(
    id: id ?? this.id,
    date: date ?? this.date,
    minute: minute ?? this.minute,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      minute: data.minute.present ? data.minute.value : this.minute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minute: $minute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, minute);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.minute == this.minute);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> minute;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.minute = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int minute,
  }) : date = Value(date),
       minute = Value(minute);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? minute,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (minute != null) 'minute': minute,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? minute,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      minute: minute ?? this.minute,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minute: $minute')
          ..write(')'))
        .toString();
  }
}

class $SessionItemsTable extends SessionItems
    with TableInfo<$SessionItemsTable, SessionItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _routineItemIdMeta = const VerificationMeta(
    'routineItemId',
  );
  @override
  late final GeneratedColumn<int> routineItemId = GeneratedColumn<int>(
    'routine_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, routineItemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('routine_item_id')) {
      context.handle(
        _routineItemIdMeta,
        routineItemId.isAcceptableOrUnknown(
          data['routine_item_id']!,
          _routineItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineItemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, routineItemId};
  @override
  SessionItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionItemRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      routineItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_item_id'],
      )!,
    );
  }

  @override
  $SessionItemsTable createAlias(String alias) {
    return $SessionItemsTable(attachedDatabase, alias);
  }
}

class SessionItemRow extends DataClass implements Insertable<SessionItemRow> {
  final int sessionId;

  /// Deliberately not a foreign key: history outlives removed routine items.
  final int routineItemId;
  const SessionItemRow({required this.sessionId, required this.routineItemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['routine_item_id'] = Variable<int>(routineItemId);
    return map;
  }

  SessionItemsCompanion toCompanion(bool nullToAbsent) {
    return SessionItemsCompanion(
      sessionId: Value(sessionId),
      routineItemId: Value(routineItemId),
    );
  }

  factory SessionItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionItemRow(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      routineItemId: serializer.fromJson<int>(json['routineItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'routineItemId': serializer.toJson<int>(routineItemId),
    };
  }

  SessionItemRow copyWith({int? sessionId, int? routineItemId}) =>
      SessionItemRow(
        sessionId: sessionId ?? this.sessionId,
        routineItemId: routineItemId ?? this.routineItemId,
      );
  SessionItemRow copyWithCompanion(SessionItemsCompanion data) {
    return SessionItemRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      routineItemId: data.routineItemId.present
          ? data.routineItemId.value
          : this.routineItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionItemRow(')
          ..write('sessionId: $sessionId, ')
          ..write('routineItemId: $routineItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, routineItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionItemRow &&
          other.sessionId == this.sessionId &&
          other.routineItemId == this.routineItemId);
}

class SessionItemsCompanion extends UpdateCompanion<SessionItemRow> {
  final Value<int> sessionId;
  final Value<int> routineItemId;
  final Value<int> rowid;
  const SessionItemsCompanion({
    this.sessionId = const Value.absent(),
    this.routineItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionItemsCompanion.insert({
    required int sessionId,
    required int routineItemId,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       routineItemId = Value(routineItemId);
  static Insertable<SessionItemRow> custom({
    Expression<int>? sessionId,
    Expression<int>? routineItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (routineItemId != null) 'routine_item_id': routineItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionItemsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? routineItemId,
    Value<int>? rowid,
  }) {
    return SessionItemsCompanion(
      sessionId: sessionId ?? this.sessionId,
      routineItemId: routineItemId ?? this.routineItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (routineItemId.present) {
      map['routine_item_id'] = Variable<int>(routineItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionItemsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('routineItemId: $routineItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _perSessionMeta = const VerificationMeta(
    'perSession',
  );
  @override
  late final GeneratedColumn<int> perSession = GeneratedColumn<int>(
    'per_session',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<bool> sound = GeneratedColumn<bool>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hapticsMeta = const VerificationMeta(
    'haptics',
  );
  @override
  late final GeneratedColumn<bool> haptics = GeneratedColumn<bool>(
    'haptics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String> theme =
      GeneratedColumn<String>(
        'theme',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ThemePreference.auto.name),
      ).withConverter<ThemePreference>($SettingsTable.$convertertheme);
  @override
  List<GeneratedColumn> get $columns => [id, perSession, sound, haptics, theme];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('per_session')) {
      context.handle(
        _perSessionMeta,
        perSession.isAcceptableOrUnknown(data['per_session']!, _perSessionMeta),
      );
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('haptics')) {
      context.handle(
        _hapticsMeta,
        haptics.isAcceptableOrUnknown(data['haptics']!, _hapticsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      perSession: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}per_session'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound'],
      )!,
      haptics: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics'],
      )!,
      theme: $SettingsTable.$convertertheme.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme'],
        )!,
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ThemePreference, String, String> $convertertheme =
      const EnumNameConverter<ThemePreference>(ThemePreference.values);
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final int id;

  /// 0 means Auto, otherwise 1 to 3.
  final int perSession;
  final bool sound;
  final bool haptics;
  final ThemePreference theme;
  const AppSettings({
    required this.id,
    required this.perSession,
    required this.sound,
    required this.haptics,
    required this.theme,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['per_session'] = Variable<int>(perSession);
    map['sound'] = Variable<bool>(sound);
    map['haptics'] = Variable<bool>(haptics);
    {
      map['theme'] = Variable<String>(
        $SettingsTable.$convertertheme.toSql(theme),
      );
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      perSession: Value(perSession),
      sound: Value(sound),
      haptics: Value(haptics),
      theme: Value(theme),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<int>(json['id']),
      perSession: serializer.fromJson<int>(json['perSession']),
      sound: serializer.fromJson<bool>(json['sound']),
      haptics: serializer.fromJson<bool>(json['haptics']),
      theme: $SettingsTable.$convertertheme.fromJson(
        serializer.fromJson<String>(json['theme']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'perSession': serializer.toJson<int>(perSession),
      'sound': serializer.toJson<bool>(sound),
      'haptics': serializer.toJson<bool>(haptics),
      'theme': serializer.toJson<String>(
        $SettingsTable.$convertertheme.toJson(theme),
      ),
    };
  }

  AppSettings copyWith({
    int? id,
    int? perSession,
    bool? sound,
    bool? haptics,
    ThemePreference? theme,
  }) => AppSettings(
    id: id ?? this.id,
    perSession: perSession ?? this.perSession,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    theme: theme ?? this.theme,
  );
  AppSettings copyWithCompanion(SettingsCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      perSession: data.perSession.present
          ? data.perSession.value
          : this.perSession,
      sound: data.sound.present ? data.sound.value : this.sound,
      haptics: data.haptics.present ? data.haptics.value : this.haptics,
      theme: data.theme.present ? data.theme.value : this.theme,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('perSession: $perSession, ')
          ..write('sound: $sound, ')
          ..write('haptics: $haptics, ')
          ..write('theme: $theme')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, perSession, sound, haptics, theme);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.perSession == this.perSession &&
          other.sound == this.sound &&
          other.haptics == this.haptics &&
          other.theme == this.theme);
}

class SettingsCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<int> perSession;
  final Value<bool> sound;
  final Value<bool> haptics;
  final Value<ThemePreference> theme;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.perSession = const Value.absent(),
    this.sound = const Value.absent(),
    this.haptics = const Value.absent(),
    this.theme = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.perSession = const Value.absent(),
    this.sound = const Value.absent(),
    this.haptics = const Value.absent(),
    this.theme = const Value.absent(),
  });
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<int>? perSession,
    Expression<bool>? sound,
    Expression<bool>? haptics,
    Expression<String>? theme,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (perSession != null) 'per_session': perSession,
      if (sound != null) 'sound': sound,
      if (haptics != null) 'haptics': haptics,
      if (theme != null) 'theme': theme,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? perSession,
    Value<bool>? sound,
    Value<bool>? haptics,
    Value<ThemePreference>? theme,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      perSession: perSession ?? this.perSession,
      sound: sound ?? this.sound,
      haptics: haptics ?? this.haptics,
      theme: theme ?? this.theme,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (perSession.present) {
      map['per_session'] = Variable<int>(perSession.value);
    }
    if (sound.present) {
      map['sound'] = Variable<bool>(sound.value);
    }
    if (haptics.present) {
      map['haptics'] = Variable<bool>(haptics.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
        $SettingsTable.$convertertheme.toSql(theme.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('perSession: $perSession, ')
          ..write('sound: $sound, ')
          ..write('haptics: $haptics, ')
          ..write('theme: $theme')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ReminderItemsTable reminderItems = $ReminderItemsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionItemsTable sessionItems = $SessionItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customExercises,
    routineItems,
    reminders,
    reminderItems,
    sessions,
    sessionItems,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reminders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      required String id,
      required String name,
      Value<String> notes,
      Value<String?> photoPath,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> notes,
      Value<String?> photoPath,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$CustomExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomExercisesTable,
          CustomExercise,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (
            CustomExercise,
            BaseReferences<
              _$AppDatabase,
              $CustomExercisesTable,
              CustomExercise
            >,
          ),
          CustomExercise,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(
    _$AppDatabase db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                name: name,
                notes: notes,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomExercisesTable, CustomExercise>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomExercisesTable,
                    CustomExercise
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomExercisesTable,
      CustomExercise,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (
        CustomExercise,
        BaseReferences<_$AppDatabase, $CustomExercisesTable, CustomExercise>,
      ),
      CustomExercise,
      PrefetchHooks Function()
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      required int position,
      required String exerciseId,
      required ExerciseMode mode,
      required int value,
      required Sides sides,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      Value<int> position,
      Value<String> exerciseId,
      Value<ExerciseMode> mode,
      Value<int> value,
      Value<Sides> sides,
    });

final class $$RoutineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineItemsTable, RoutineItem> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReminderItemsTable, List<ReminderItemRow>>
  _reminderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderItems,
    aliasName: 'routine_items__id__reminder_items__routine_item_id',
  );

  $$ReminderItemsTableProcessedTableManager get reminderItemsRefs {
    final manager = $$ReminderItemsTableTableManager(
      $_db,
      $_db.reminderItems,
    ).filter((f) => f.routineItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseMode, ExerciseMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sides, Sides, String> get sides =>
      $composableBuilder(
        column: $table.sides,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> reminderItemsRefs(
    Expression<bool> Function($$ReminderItemsTableFilterComposer f) f,
  ) {
    final $$ReminderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderItems,
      getReferencedColumn: (t) => t.routineItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderItemsTableFilterComposer(
            $db: $db,
            $table: $db.reminderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sides => $composableBuilder(
    column: $table.sides,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ExerciseMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sides, String> get sides =>
      $composableBuilder(column: $table.sides, builder: (column) => column);

  Expression<T> reminderItemsRefs<T extends Object>(
    Expression<T> Function($$ReminderItemsTableAnnotationComposer a) f,
  ) {
    final $$ReminderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderItems,
      getReferencedColumn: (t) => t.routineItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineItemsTable,
          RoutineItem,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItem, $$RoutineItemsTableReferences),
          RoutineItem,
          PrefetchHooks Function({bool reminderItemsRefs})
        > {
  $$RoutineItemsTableTableManager(_$AppDatabase db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<ExerciseMode> mode = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<Sides> sides = const Value.absent(),
              }) => RoutineItemsCompanion(
                id: id,
                position: position,
                exerciseId: exerciseId,
                mode: mode,
                value: value,
                sides: sides,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int position,
                required String exerciseId,
                required ExerciseMode mode,
                required int value,
                required Sides sides,
              }) => RoutineItemsCompanion.insert(
                id: id,
                position: position,
                exerciseId: exerciseId,
                mode: mode,
                value: value,
                sides: sides,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineItemsTable, RoutineItem>(table),
                  $$RoutineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reminderItemsRefs) db.reminderItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reminderItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      RoutineItem,
                      $RoutineItemsTable,
                      ReminderItemRow,
                      $ReminderItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RoutineItemsTableReferences
                          ._reminderItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).reminderItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'routine_item_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineItemsTable,
      RoutineItem,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItem, $$RoutineItemsTableReferences),
      RoutineItem,
      PrefetchHooks Function({bool reminderItemsRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required ReminderType type,
  required int intervalMinutes,
  required int startMinute,
  required int endMinute,
  required List<int> times,
  required ReminderScope scope,
  required bool enabled,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<ReminderType> type,
  Value<int> intervalMinutes,
  Value<int> startMinute,
  Value<int> endMinute,
  Value<List<int>> times,
  Value<ReminderScope> scope,
  Value<bool> enabled,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReminderItemsTable, List<ReminderItemRow>>
  _reminderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderItems,
    aliasName: 'reminders__id__reminder_items__reminder_id',
  );

  $$ReminderItemsTableProcessedTableManager get reminderItemsRefs {
    final manager = $$ReminderItemsTableTableManager(
      $_db,
      $_db.reminderItems,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get times =>
      $composableBuilder(
        column: $table.times,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ReminderScope, ReminderScope, String>
  get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reminderItemsRefs(
    Expression<bool> Function($$ReminderItemsTableFilterComposer f) f,
  ) {
    final $$ReminderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderItems,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderItemsTableFilterComposer(
            $db: $db,
            $table: $db.reminderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderScope, String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  Expression<T> reminderItemsRefs<T extends Object>(
    Expression<T> Function($$ReminderItemsTableAnnotationComposer a) f,
  ) {
    final $$ReminderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderItems,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool reminderItemsRefs})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ReminderType> type = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<List<int>> times = const Value.absent(),
                Value<ReminderScope> scope = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                type: type,
                intervalMinutes: intervalMinutes,
                startMinute: startMinute,
                endMinute: endMinute,
                times: times,
                scope: scope,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ReminderType type,
                required int intervalMinutes,
                required int startMinute,
                required int endMinute,
                required List<int> times,
                required ReminderScope scope,
                required bool enabled,
              }) => RemindersCompanion.insert(
                id: id,
                type: type,
                intervalMinutes: intervalMinutes,
                startMinute: startMinute,
                endMinute: endMinute,
                times: times,
                scope: scope,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reminderItemsRefs) db.reminderItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reminderItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      ReminderRow,
                      $RemindersTable,
                      ReminderItemRow,
                      $ReminderItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RemindersTableReferences
                          ._reminderItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RemindersTableReferences(
                            db,
                            table,
                            p0,
                          ).reminderItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'reminder_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool reminderItemsRefs})
    >;
typedef $$ReminderItemsTableCreateCompanionBuilder =
    ReminderItemsCompanion Function({
      required int reminderId,
      required int routineItemId,
      Value<int> rowid,
    });
typedef $$ReminderItemsTableUpdateCompanionBuilder =
    ReminderItemsCompanion Function({
      Value<int> reminderId,
      Value<int> routineItemId,
      Value<int> rowid,
    });

final class $$ReminderItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReminderItemsTable, ReminderItemRow> {
  $$ReminderItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RemindersTable _reminderIdTable(_$AppDatabase db) =>
      db.reminders.createAlias('reminder_items__reminder_id__reminders__id');

  $$RemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<int>('reminder_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutineItemsTable _routineItemIdTable(_$AppDatabase db) => db
      .routineItems
      .createAlias('reminder_items__routine_item_id__routine_items__id');

  $$RoutineItemsTableProcessedTableManager get routineItemId {
    final $_column = $_itemColumn<int>('routine_item_id')!;

    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderItemsTable> {
  $$ReminderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RemindersTableFilterComposer get reminderId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineItemsTableFilterComposer get routineItemId {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderItemsTable> {
  $$ReminderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RemindersTableOrderingComposer get reminderId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineItemsTableOrderingComposer get routineItemId {
    final $$RoutineItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableOrderingComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderItemsTable> {
  $$ReminderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RemindersTableAnnotationComposer get reminderId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineItemsTableAnnotationComposer get routineItemId {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderItemsTable,
          ReminderItemRow,
          $$ReminderItemsTableFilterComposer,
          $$ReminderItemsTableOrderingComposer,
          $$ReminderItemsTableAnnotationComposer,
          $$ReminderItemsTableCreateCompanionBuilder,
          $$ReminderItemsTableUpdateCompanionBuilder,
          (ReminderItemRow, $$ReminderItemsTableReferences),
          ReminderItemRow,
          PrefetchHooks Function({bool reminderId, bool routineItemId})
        > {
  $$ReminderItemsTableTableManager(_$AppDatabase db, $ReminderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> reminderId = const Value.absent(),
                Value<int> routineItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderItemsCompanion(
                reminderId: reminderId,
                routineItemId: routineItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int reminderId,
                required int routineItemId,
                Value<int> rowid = const Value.absent(),
              }) => ReminderItemsCompanion.insert(
                reminderId: reminderId,
                routineItemId: routineItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderItemsTable, ReminderItemRow>(table),
                  $$ReminderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderId = false, routineItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reminderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reminderId,
                        referencedTable: $$ReminderItemsTableReferences
                            ._reminderIdTable(db),
                        referencedColumn: $$ReminderItemsTableReferences
                            ._reminderIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (routineItemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineItemId,
                        referencedTable: $$ReminderItemsTableReferences
                            ._routineItemIdTable(db),
                        referencedColumn: $$ReminderItemsTableReferences
                            ._routineItemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderItemsTable,
      ReminderItemRow,
      $$ReminderItemsTableFilterComposer,
      $$ReminderItemsTableOrderingComposer,
      $$ReminderItemsTableAnnotationComposer,
      $$ReminderItemsTableCreateCompanionBuilder,
      $$ReminderItemsTableUpdateCompanionBuilder,
      (ReminderItemRow, $$ReminderItemsTableReferences),
      ReminderItemRow,
      PrefetchHooks Function({bool reminderId, bool routineItemId})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String date,
  required int minute,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<int> minute,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionItemsTable, List<SessionItemRow>>
  _sessionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionItems,
    aliasName: 'sessions__id__session_items__session_id',
  );

  $$SessionItemsTableProcessedTableManager get sessionItemsRefs {
    final manager = $$SessionItemsTableTableManager(
      $_db,
      $_db.sessionItems,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionItemsRefs(
    Expression<bool> Function($$SessionItemsTableFilterComposer f) f,
  ) {
    final $$SessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  Expression<T> sessionItemsRefs<T extends Object>(
    Expression<T> Function($$SessionItemsTableAnnotationComposer a) f,
  ) {
    final $$SessionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool sessionItemsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> minute = const Value.absent(),
          }) => SessionsCompanion(id: id, date: date, minute: minute),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required int minute,
          }) => SessionsCompanion.insert(id: id, date: date, minute: minute),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionRow>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionItemsRefs) db.sessionItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      SessionRow,
                      $SessionsTable,
                      SessionItemRow,
                      $SessionItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._sessionItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionsTableReferences(
                        db,
                        table,
                        p0,
                      ).sessionItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool sessionItemsRefs})
    >;
typedef $$SessionItemsTableCreateCompanionBuilder =
    SessionItemsCompanion Function({
      required int sessionId,
      required int routineItemId,
      Value<int> rowid,
    });
typedef $$SessionItemsTableUpdateCompanionBuilder =
    SessionItemsCompanion Function({
      Value<int> sessionId,
      Value<int> routineItemId,
      Value<int> rowid,
    });

final class $$SessionItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionItemsTable, SessionItemRow> {
  $$SessionItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_items__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionItemsTable,
          SessionItemRow,
          $$SessionItemsTableFilterComposer,
          $$SessionItemsTableOrderingComposer,
          $$SessionItemsTableAnnotationComposer,
          $$SessionItemsTableCreateCompanionBuilder,
          $$SessionItemsTableUpdateCompanionBuilder,
          (SessionItemRow, $$SessionItemsTableReferences),
          SessionItemRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionItemsTableTableManager(_$AppDatabase db, $SessionItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<int> routineItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionItemsCompanion(
                sessionId: sessionId,
                routineItemId: routineItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sessionId,
                required int routineItemId,
                Value<int> rowid = const Value.absent(),
              }) => SessionItemsCompanion.insert(
                sessionId: sessionId,
                routineItemId: routineItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionItemsTable, SessionItemRow>(table),
                  $$SessionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionItemsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionItemsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionItemsTable,
      SessionItemRow,
      $$SessionItemsTableFilterComposer,
      $$SessionItemsTableOrderingComposer,
      $$SessionItemsTableAnnotationComposer,
      $$SessionItemsTableCreateCompanionBuilder,
      $$SessionItemsTableUpdateCompanionBuilder,
      (SessionItemRow, $$SessionItemsTableReferences),
      SessionItemRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> perSession,
  Value<bool> sound,
  Value<bool> haptics,
  Value<ThemePreference> theme,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> perSession,
  Value<bool> sound,
  Value<bool> haptics,
  Value<ThemePreference> theme,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perSession => $composableBuilder(
    column: $table.perSession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get haptics => $composableBuilder(
    column: $table.haptics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perSession => $composableBuilder(
    column: $table.perSession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get haptics => $composableBuilder(
    column: $table.haptics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get perSession => $composableBuilder(
    column: $table.perSession,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<bool> get haptics =>
      $composableBuilder(column: $table.haptics, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThemePreference, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          AppSettings,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            AppSettings,
            BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>,
          ),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> perSession = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> haptics = const Value.absent(),
                Value<ThemePreference> theme = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                perSession: perSession,
                sound: sound,
                haptics: haptics,
                theme: theme,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> perSession = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> haptics = const Value.absent(),
                Value<ThemePreference> theme = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                perSession: perSession,
                sound: sound,
                haptics: haptics,
                theme: theme,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, AppSettings>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      AppSettings,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (AppSettings, BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>),
      AppSettings,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ReminderItemsTableTableManager get reminderItems =>
      $$ReminderItemsTableTableManager(_db, _db.reminderItems);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionItemsTableTableManager get sessionItems =>
      $$SessionItemsTableTableManager(_db, _db.sessionItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
