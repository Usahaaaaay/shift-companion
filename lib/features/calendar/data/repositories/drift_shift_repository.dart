// drift_shift_repository.dart
//
// A SQLite-backed ShiftRepository implementation (Phase 3.2A), reading and
// writing through an injected AppDatabase. Not wired into the running app
// yet — MemoryShiftRepository remains what routing/app_router.dart
// constructs; that swap is a separate, later step (Phase 3.2B), by design,
// so this class can be reviewed as a self-contained unit first.
//
// No Drift type (Shift, ShiftsCompanion, AppDatabase) appears in this
// class's public API — every public method takes/returns only DateTime,
// ShiftType, ShiftDetails, or a plain Map of them, matching
// ShiftRepository's contract exactly. The private _toDomain/_toCompanion
// helpers are the only place Drift's generated types are touched.
//
// PHASE 3.4: added the four Shift Template methods ShiftRepository now
// declares, plus [breakMinutes] on the existing Shift conversions. Same
// rule applies to the new methods: no Drift type crosses this class's
// public API, only ShiftTemplate/int/List of them — _toDomainTemplate/
// _toCompanionTemplate are the template equivalent of _toDomain/
// _toCompanion below.

import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_template.dart';
import '../../domain/repositories/shift_repository.dart';

/// A [ShiftRepository] backed by Drift/SQLite via [AppDatabase].
class DriftShiftRepository implements ShiftRepository {
  /// Creates a [DriftShiftRepository] reading and writing through [_db].
  ///
  /// [_db] is injected, not constructed here — this class doesn't know or
  /// care how the database was opened, matching the same "receive your
  /// dependency" shape CalendarScreen already uses for [ShiftRepository]
  /// itself.
  DriftShiftRepository(this._db);

  final AppDatabase _db;

  /// Normalizes [date] to a bare year/month/day value (no time-of-day
  /// component) — the same convention MemoryShiftRepository already
  /// enforces, applied here before every insert, update, delete, and
  /// query, so every calendar day maps to exactly one row. The `Shifts`
  /// table's uniqueness constraint on `date` (see shift_table.dart) backs
  /// this up at the database level too.
  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<ShiftDetails?> getShift(DateTime date) async {
    final row = await (_db.select(
      _db.shifts,
    )..where((t) => t.date.equals(_normalizeDate(date)))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Map<DateTime, ShiftDetails>> getAllShifts() async {
    final rows = await _db.select(_db.shifts).get();
    return {for (final row in rows) row.date: _toDomain(row)};
  }

  @override
  Future<void> saveShift(DateTime date, ShiftDetails details) async {
    final normalizedDate = _normalizeDate(date);
    await _db
        .into(_db.shifts)
        .insert(
          _toCompanion(normalizedDate, details),
          // Explicit conflict target (rather than relying on
          // insertOnConflictUpdate's default, which resolves against the
          // primary key — `id`, which is never supplied on insert and so
          // would never actually conflict): this is genuinely an
          // upsert-by-date, matching the `date` uniqueness constraint the
          // table declares.
          onConflict: DoUpdate(
            (_) => _toCompanion(normalizedDate, details),
            target: [_db.shifts.date],
          ),
        );
  }

  @override
  Future<void> deleteShift(DateTime date) async {
    await (_db.delete(
      _db.shifts,
    )..where((t) => t.date.equals(_normalizeDate(date)))).go();
  }

  @override
  Future<List<ShiftTemplate>> getTemplates() async {
    final rows = await _db.select(_db.shiftTemplates).get();
    return rows.map(_toDomainTemplate).toList();
  }

  @override
  Future<void> saveTemplate(ShiftTemplate template) async {
    await _db.into(_db.shiftTemplates).insert(_toCompanionTemplate(template));
  }

  @override
  Future<void> updateTemplate(ShiftTemplate template) async {
    // template.id is required to target the existing row — see
    // ShiftRepository.updateTemplate's own doc comment.
    await (_db.update(_db.shiftTemplates)
          ..where((t) => t.id.equals(template.id!)))
        .write(_toCompanionTemplate(template));
  }

  @override
  Future<void> deleteTemplate(int id) async {
    await (_db.delete(_db.shiftTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// Converts a stored row into the domain [ShiftDetails] the rest of the
  /// app works with. `notes` has no column yet (see shift_table.dart's
  /// scope note), so it's always `null` here for now.
  static ShiftDetails _toDomain(Shift row) {
    return ShiftDetails(
      type: row.shiftType,
      startTime: row.startTime,
      endTime: row.endTime,
      hours: row.hours,
      breakMinutes: row.breakMinutes,
    );
  }

  /// Converts a domain [ShiftDetails] into the row shape Drift's generated
  /// insert/update API expects.
  static ShiftsCompanion _toCompanion(
    DateTime normalizedDate,
    ShiftDetails details,
  ) {
    return ShiftsCompanion.insert(
      date: normalizedDate,
      shiftType: details.type,
      startTime: Value(details.startTime),
      endTime: Value(details.endTime),
      hours: Value(details.hours),
      breakMinutes: Value(details.breakMinutes),
    );
  }

  /// Converts a stored row into the domain [ShiftTemplate] the rest of the
  /// app works with.
  static ShiftTemplate _toDomainTemplate(ShiftTemplateRow row) {
    return ShiftTemplate(
      id: row.id,
      name: row.name,
      startMinutes: row.startMinutes,
      endMinutes: row.endMinutes,
      breakMinutes: row.breakMinutes,
      notes: row.defaultNotes,
    );
  }

  /// Converts a domain [ShiftTemplate] into the row shape Drift's generated
  /// insert/update API expects. [template.id] is deliberately not carried
  /// across here — [saveTemplate] never needs it (a new id is always
  /// assigned), and [updateTemplate] targets it separately via its own
  /// `where` clause rather than as part of the written row.
  static ShiftTemplatesCompanion _toCompanionTemplate(ShiftTemplate template) {
    return ShiftTemplatesCompanion.insert(
      name: template.name,
      startMinutes: template.startMinutes,
      endMinutes: template.endMinutes,
      breakMinutes: template.breakMinutes,
      defaultNotes: Value(template.notes),
    );
  }
}
