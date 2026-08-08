// shift_table.dart
//
// The Drift table definition for stored shifts. Lives in data/datasources/
// per ARCHITECTURE.md, which names Drift explicitly as an example of what
// belongs there: "local (e.g. Drift/SharedPreferences)... sources".
//
// This table is registered with lib/database/app_database.dart (a
// top-level file, not inside this feature) — see that file's header
// comment for why the database itself lives outside features/ while this
// table definition lives inside one.
//
// SCHEMA SCOPE: id, date, startTime, endTime, shiftType, hours — every
// field on ShiftDetails except `notes`, which stays deliberately deferred
// (along with overtimeMinutes, leaveType, createdAt, updatedAt). Adding
// any of those later is a normal Drift migration: add the column here,
// bump AppDatabase.schemaVersion, and add a migration step in
// AppDatabase's `migration` getter.
//
// PHASE 3.2A: added [hours] (was flagged as a gap in Phase 3.1 — the
// domain entity already had it, the "at minimum" column list that phase
// was given didn't) and a uniqueness constraint on [date]. The constraint
// isn't cosmetic: it's what makes "one canonical key per calendar day"
// (this phase's own normalization requirement) an actual database
// guarantee rather than just an application-level convention, and it's
// required for DriftShiftRepository's upsert-by-date to behave correctly
// — see that file for how `saveShift` targets this constraint explicitly.

import 'package:drift/drift.dart';
import '../../domain/entities/shift_type.dart';

/// Drift table storing one row per scheduled shift.
///
/// [ShiftType] is reused directly from the domain layer via
/// [textEnum] — the data layer is allowed to depend on domain entities
/// (ARCHITECTURE.md's `data → domain` dependency direction), and storing
/// the enum by name (rather than a raw integer index, or a second,
/// hand-maintained string mapping) means the column can't silently drift
/// out of sync with the enum it represents.
class Shifts extends Table {
  /// Auto-incrementing row id — Drift recognizes a column named exactly
  /// `id` with `autoIncrement()` as this table's primary key automatically.
  IntColumn get id => integer().autoIncrement()();

  /// The date this shift falls on. Expected to be normalized to a bare
  /// year/month/day value by the repository layer before ever reaching
  /// this table (see DriftShiftRepository) — enforced here too via
  /// `.unique()`, so a bug upstream can't silently create two rows for
  /// what should be the same calendar day.
  DateTimeColumn get date => dateTime().unique()();

  /// Formatted start time, e.g. "7:00 AM" — nullable, matching
  /// [ShiftDetails.startTime] (some shift types, like a day off, have no
  /// meaningful time range).
  TextColumn get startTime => text().nullable()();

  /// Formatted end time, e.g. "4:30 PM" — nullable, matching
  /// [ShiftDetails.endTime] for the same reason as [startTime].
  TextColumn get endTime => text().nullable()();

  /// Total hours for the shift, e.g. 9.5 — nullable, matching
  /// [ShiftDetails.hours] for the same reason as [startTime].
  RealColumn get hours => real().nullable()();

  /// Which kind of shift this is, stored as the [ShiftType] enum's name.
  TextColumn get shiftType => textEnum<ShiftType>()();
}
