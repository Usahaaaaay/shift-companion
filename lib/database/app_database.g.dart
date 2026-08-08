// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hoursMeta = const VerificationMeta('hours');
  @override
  late final GeneratedColumn<double> hours = GeneratedColumn<double>(
    'hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ShiftType, String> shiftType =
      GeneratedColumn<String>(
        'shift_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ShiftType>($ShiftsTable.$convertershiftType);
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    startTime,
    endTime,
    hours,
    shiftType,
    breakMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
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
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('hours')) {
      context.handle(
        _hoursMeta,
        hours.isAcceptableOrUnknown(data['hours']!, _hoursMeta),
      );
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      hours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours'],
      ),
      shiftType: $ShiftsTable.$convertershiftType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shift_type'],
        )!,
      ),
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ShiftType, String, String> $convertershiftType =
      const EnumNameConverter<ShiftType>(ShiftType.values);
}

class Shift extends DataClass implements Insertable<Shift> {
  /// Auto-incrementing row id — Drift recognizes a column named exactly
  /// `id` with `autoIncrement()` as this table's primary key automatically.
  final int id;

  /// The date this shift falls on. Expected to be normalized to a bare
  /// year/month/day value by the repository layer before ever reaching
  /// this table (see DriftShiftRepository) — enforced here too via
  /// `.unique()`, so a bug upstream can't silently create two rows for
  /// what should be the same calendar day.
  final DateTime date;

  /// Formatted start time, e.g. "7:00 AM" — nullable, matching
  /// [ShiftDetails.startTime] (some shift types, like a day off, have no
  /// meaningful time range).
  final String? startTime;

  /// Formatted end time, e.g. "4:30 PM" — nullable, matching
  /// [ShiftDetails.endTime] for the same reason as [startTime].
  final String? endTime;

  /// Total hours for the shift, e.g. 9.5 — nullable, matching
  /// [ShiftDetails.hours] for the same reason as [startTime].
  final double? hours;

  /// Which kind of shift this is, stored as the [ShiftType] enum's name.
  final ShiftType shiftType;

  /// The shift's unpaid break length, in minutes — nullable, matching
  /// [ShiftDetails.breakMinutes] for the same reason as [startTime]: not
  /// every shift type has a meaningful break.
  final int? breakMinutes;
  const Shift({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.hours,
    required this.shiftType,
    this.breakMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || hours != null) {
      map['hours'] = Variable<double>(hours);
    }
    {
      map['shift_type'] = Variable<String>(
        $ShiftsTable.$convertershiftType.toSql(shiftType),
      );
    }
    if (!nullToAbsent || breakMinutes != null) {
      map['break_minutes'] = Variable<int>(breakMinutes);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      date: Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      hours: hours == null && nullToAbsent
          ? const Value.absent()
          : Value(hours),
      shiftType: Value(shiftType),
      breakMinutes: breakMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(breakMinutes),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      hours: serializer.fromJson<double?>(json['hours']),
      shiftType: $ShiftsTable.$convertershiftType.fromJson(
        serializer.fromJson<String>(json['shiftType']),
      ),
      breakMinutes: serializer.fromJson<int?>(json['breakMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'hours': serializer.toJson<double?>(hours),
      'shiftType': serializer.toJson<String>(
        $ShiftsTable.$convertershiftType.toJson(shiftType),
      ),
      'breakMinutes': serializer.toJson<int?>(breakMinutes),
    };
  }

  Shift copyWith({
    int? id,
    DateTime? date,
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    Value<double?> hours = const Value.absent(),
    ShiftType? shiftType,
    Value<int?> breakMinutes = const Value.absent(),
  }) => Shift(
    id: id ?? this.id,
    date: date ?? this.date,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    hours: hours.present ? hours.value : this.hours,
    shiftType: shiftType ?? this.shiftType,
    breakMinutes: breakMinutes.present ? breakMinutes.value : this.breakMinutes,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      hours: data.hours.present ? data.hours.value : this.hours,
      shiftType: data.shiftType.present ? data.shiftType.value : this.shiftType,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('hours: $hours, ')
          ..write('shiftType: $shiftType, ')
          ..write('breakMinutes: $breakMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, startTime, endTime, hours, shiftType, breakMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.hours == this.hours &&
          other.shiftType == this.shiftType &&
          other.breakMinutes == this.breakMinutes);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<double?> hours;
  final Value<ShiftType> shiftType;
  final Value<int?> breakMinutes;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.hours = const Value.absent(),
    this.shiftType = const Value.absent(),
    this.breakMinutes = const Value.absent(),
  });
  ShiftsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.hours = const Value.absent(),
    required ShiftType shiftType,
    this.breakMinutes = const Value.absent(),
  }) : date = Value(date),
       shiftType = Value(shiftType);
  static Insertable<Shift> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<double>? hours,
    Expression<String>? shiftType,
    Expression<int>? breakMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (hours != null) 'hours': hours,
      if (shiftType != null) 'shift_type': shiftType,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
    });
  }

  ShiftsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<double?>? hours,
    Value<ShiftType>? shiftType,
    Value<int?>? breakMinutes,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hours: hours ?? this.hours,
      shiftType: shiftType ?? this.shiftType,
      breakMinutes: breakMinutes ?? this.breakMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (hours.present) {
      map['hours'] = Variable<double>(hours.value);
    }
    if (shiftType.present) {
      map['shift_type'] = Variable<String>(
        $ShiftsTable.$convertershiftType.toSql(shiftType.value),
      );
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('hours: $hours, ')
          ..write('shiftType: $shiftType, ')
          ..write('breakMinutes: $breakMinutes')
          ..write(')'))
        .toString();
  }
}

class $ShiftTemplatesTable extends ShiftTemplates
    with TableInfo<$ShiftTemplatesTable, ShiftTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultNotesMeta = const VerificationMeta(
    'defaultNotes',
  );
  @override
  late final GeneratedColumn<String> defaultNotes = GeneratedColumn<String>(
    'default_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startMinutes,
    endMinutes,
    breakMinutes,
    defaultNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_breakMinutesMeta);
    }
    if (data.containsKey('default_notes')) {
      context.handle(
        _defaultNotesMeta,
        defaultNotes.isAcceptableOrUnknown(
          data['default_notes']!,
          _defaultNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      )!,
      defaultNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_notes'],
      ),
    );
  }

  @override
  $ShiftTemplatesTable createAlias(String alias) {
    return $ShiftTemplatesTable(attachedDatabase, alias);
  }
}

class ShiftTemplateRow extends DataClass
    implements Insertable<ShiftTemplateRow> {
  /// Auto-incrementing row id — Drift recognizes a column named exactly
  /// `id` with `autoIncrement()` as this table's primary key automatically.
  final int id;

  /// A short, user-facing name, e.g. "Morning".
  final String name;

  /// This template's start time, in minutes since midnight.
  final int startMinutes;

  /// This template's finish time, in minutes since midnight. May be
  /// numerically less than [startMinutes] for an overnight shift.
  final int endMinutes;

  /// This template's default unpaid break length, in minutes.
  final int breakMinutes;

  /// An optional default note pre-filled into the shift form's Notes field
  /// when this template is applied.
  final String? defaultNotes;
  const ShiftTemplateRow({
    required this.id,
    required this.name,
    required this.startMinutes,
    required this.endMinutes,
    required this.breakMinutes,
    this.defaultNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['break_minutes'] = Variable<int>(breakMinutes);
    if (!nullToAbsent || defaultNotes != null) {
      map['default_notes'] = Variable<String>(defaultNotes);
    }
    return map;
  }

  ShiftTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ShiftTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      breakMinutes: Value(breakMinutes),
      defaultNotes: defaultNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultNotes),
    );
  }

  factory ShiftTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftTemplateRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      defaultNotes: serializer.fromJson<String?>(json['defaultNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'defaultNotes': serializer.toJson<String?>(defaultNotes),
    };
  }

  ShiftTemplateRow copyWith({
    int? id,
    String? name,
    int? startMinutes,
    int? endMinutes,
    int? breakMinutes,
    Value<String?> defaultNotes = const Value.absent(),
  }) => ShiftTemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    defaultNotes: defaultNotes.present ? defaultNotes.value : this.defaultNotes,
  );
  ShiftTemplateRow copyWithCompanion(ShiftTemplatesCompanion data) {
    return ShiftTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      defaultNotes: data.defaultNotes.present
          ? data.defaultNotes.value
          : this.defaultNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftTemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('defaultNotes: $defaultNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startMinutes,
    endMinutes,
    breakMinutes,
    defaultNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftTemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.breakMinutes == this.breakMinutes &&
          other.defaultNotes == this.defaultNotes);
}

class ShiftTemplatesCompanion extends UpdateCompanion<ShiftTemplateRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<int> breakMinutes;
  final Value<String?> defaultNotes;
  const ShiftTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.defaultNotes = const Value.absent(),
  });
  ShiftTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
    this.defaultNotes = const Value.absent(),
  }) : name = Value(name),
       startMinutes = Value(startMinutes),
       endMinutes = Value(endMinutes),
       breakMinutes = Value(breakMinutes);
  static Insertable<ShiftTemplateRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? breakMinutes,
    Expression<String>? defaultNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (defaultNotes != null) 'default_notes': defaultNotes,
    });
  }

  ShiftTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<int>? breakMinutes,
    Value<String?>? defaultNotes,
  }) {
    return ShiftTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      defaultNotes: defaultNotes ?? this.defaultNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (defaultNotes.present) {
      map['default_notes'] = Variable<String>(defaultNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('defaultNotes: $defaultNotes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $ShiftTemplatesTable shiftTemplates = $ShiftTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [shifts, shiftTemplates];
}

typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<double?> hours,
      required ShiftType shiftType,
      Value<int?> breakMinutes,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<double?> hours,
      Value<ShiftType> shiftType,
      Value<int?> breakMinutes,
    });

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ShiftType, ShiftType, String> get shiftType =>
      $composableBuilder(
        column: $table.shiftType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftType => $composableBuilder(
    column: $table.shiftType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get hours =>
      $composableBuilder(column: $table.hours, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ShiftType, String> get shiftType =>
      $composableBuilder(column: $table.shiftType, builder: (column) => column);

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
          Shift,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<double?> hours = const Value.absent(),
                Value<ShiftType> shiftType = const Value.absent(),
                Value<int?> breakMinutes = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                date: date,
                startTime: startTime,
                endTime: endTime,
                hours: hours,
                shiftType: shiftType,
                breakMinutes: breakMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<double?> hours = const Value.absent(),
                required ShiftType shiftType,
                Value<int?> breakMinutes = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                date: date,
                startTime: startTime,
                endTime: endTime,
                hours: hours,
                shiftType: shiftType,
                breakMinutes: breakMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
      Shift,
      PrefetchHooks Function()
    >;
typedef $$ShiftTemplatesTableCreateCompanionBuilder =
    ShiftTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required int startMinutes,
      required int endMinutes,
      required int breakMinutes,
      Value<String?> defaultNotes,
    });
typedef $$ShiftTemplatesTableUpdateCompanionBuilder =
    ShiftTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<int> breakMinutes,
      Value<String?> defaultNotes,
    });

class $$ShiftTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftTemplatesTable> {
  $$ShiftTemplatesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultNotes => $composableBuilder(
    column: $table.defaultNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftTemplatesTable> {
  $$ShiftTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultNotes => $composableBuilder(
    column: $table.defaultNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftTemplatesTable> {
  $$ShiftTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultNotes => $composableBuilder(
    column: $table.defaultNotes,
    builder: (column) => column,
  );
}

class $$ShiftTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftTemplatesTable,
          ShiftTemplateRow,
          $$ShiftTemplatesTableFilterComposer,
          $$ShiftTemplatesTableOrderingComposer,
          $$ShiftTemplatesTableAnnotationComposer,
          $$ShiftTemplatesTableCreateCompanionBuilder,
          $$ShiftTemplatesTableUpdateCompanionBuilder,
          (
            ShiftTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $ShiftTemplatesTable,
              ShiftTemplateRow
            >,
          ),
          ShiftTemplateRow,
          PrefetchHooks Function()
        > {
  $$ShiftTemplatesTableTableManager(
    _$AppDatabase db,
    $ShiftTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<String?> defaultNotes = const Value.absent(),
              }) => ShiftTemplatesCompanion(
                id: id,
                name: name,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                breakMinutes: breakMinutes,
                defaultNotes: defaultNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int startMinutes,
                required int endMinutes,
                required int breakMinutes,
                Value<String?> defaultNotes = const Value.absent(),
              }) => ShiftTemplatesCompanion.insert(
                id: id,
                name: name,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                breakMinutes: breakMinutes,
                defaultNotes: defaultNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftTemplatesTable,
      ShiftTemplateRow,
      $$ShiftTemplatesTableFilterComposer,
      $$ShiftTemplatesTableOrderingComposer,
      $$ShiftTemplatesTableAnnotationComposer,
      $$ShiftTemplatesTableCreateCompanionBuilder,
      $$ShiftTemplatesTableUpdateCompanionBuilder,
      (
        ShiftTemplateRow,
        BaseReferences<_$AppDatabase, $ShiftTemplatesTable, ShiftTemplateRow>,
      ),
      ShiftTemplateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$ShiftTemplatesTableTableManager get shiftTemplates =>
      $$ShiftTemplatesTableTableManager(_db, _db.shiftTemplates);
}
