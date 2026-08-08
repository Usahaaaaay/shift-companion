// shift_template_table.dart
//
// The Drift table definition for stored shift templates (Phase 3.4). Lives
// alongside shift_table.dart in data/datasources/ — see that file's header
// comment for why this folder is where Drift table definitions belong.
//
// Registered with lib/database/app_database.dart, same as [Shifts].
//
// SCHEMA: id, name, startMinutes, endMinutes, breakMinutes, defaultNotes —
// exactly what this phase's brief specifies. Times are stored as plain
// integers (minutes since midnight), not formatted strings — see
// ../../domain/entities/shift_template.dart's header comment and
// decisions/0003-shift-templates-minutes-storage.md for why.

import 'package:drift/drift.dart';

/// Drift table storing one row per reusable shift template.
///
/// `@DataClassName('ShiftTemplateRow')` because Drift's default naming
/// would otherwise generate a row class called `ShiftTemplate` — colliding
/// with the domain entity of the same name (see
/// ../../domain/entities/shift_template.dart). `Shifts` doesn't have this
/// problem (its generated `Shift` class has no same-named domain
/// counterpart — the domain entity is `ShiftDetails`), so this is the
/// first table in this codebase that needs the explicit override.
@DataClassName('ShiftTemplateRow')
class ShiftTemplates extends Table {
  /// Auto-incrementing row id — Drift recognizes a column named exactly
  /// `id` with `autoIncrement()` as this table's primary key automatically.
  IntColumn get id => integer().autoIncrement()();

  /// A short, user-facing name, e.g. "Morning".
  TextColumn get name => text()();

  /// This template's start time, in minutes since midnight.
  IntColumn get startMinutes => integer()();

  /// This template's finish time, in minutes since midnight. May be
  /// numerically less than [startMinutes] for an overnight shift.
  IntColumn get endMinutes => integer()();

  /// This template's default unpaid break length, in minutes.
  IntColumn get breakMinutes => integer()();

  /// An optional default note pre-filled into the shift form's Notes field
  /// when this template is applied.
  TextColumn get defaultNotes => text().nullable()();
}
