// shift_repository.dart
//
// The Calendar feature's shift-storage contract (Phase 2.6). Pure Dart —
// no Flutter imports — per ARCHITECTURE.md's domain-layer rule: this file
// describes *what* shift storage can do, not *how*. CalendarScreen depends
// on this interface, never on a concrete implementation (see
// data/repositories/memory_shift_repository.dart and
// data/repositories/drift_shift_repository.dart), so swapping storage
// later means writing a new class that implements this contract, not
// touching the UI.
//
// Declared `abstract interface class` rather than plain `abstract class`:
// this type exists to be implemented (`implements`), not extended, and
// Dart 3's class modifiers let that intent be checked by the compiler
// instead of just documented in a comment.
//
// PHASE 3.2A: every method is now `Future`-returning. Real SQLite access
// through Drift is inherently asynchronous — a `DriftShiftRepository`
// cannot honestly implement a synchronous contract without either
// blocking (not viable in Dart without unsafe workarounds) or hiding an
// eager in-memory cache behind a sync facade. This project deliberately
// chose the textbook-correct shape instead: an async interface, with
// `MemoryShiftRepository` trivially adapted to match (in-memory reads/
// writes just complete immediately inside an `async` function), and the
// small necessary follow-on change to CalendarBottomSheet/CalendarScreen
// to await these calls (see those files' own Phase 3.2A notes).
//
// PHASE 3.4: added the four Shift Template methods below. They live on
// this same interface — rather than a separate `ShiftTemplateRepository`
// — per this phase's own brief ("extend the repository abstraction");
// CalendarScreen still only ever depends on one repository type for all
// of its Calendar-feature storage needs, matching the shape this
// interface already had. Both `DriftShiftRepository` and
// `MemoryShiftRepository` implement all four, same as every other method
// here.

import '../entities/shift_details.dart';
import '../entities/shift_template.dart';

/// A contract for storing and retrieving a single user's shift schedule,
/// keyed by date, plus that user's reusable Shift Templates.
abstract interface class ShiftRepository {
  /// Returns the shift assigned to [date], or `null` if none exists.
  Future<ShiftDetails?> getShift(DateTime date);

  /// Returns every currently-stored shift, keyed by date. The returned map
  /// is a snapshot at the time this completes — mutating it does not
  /// affect this repository's stored data; use [saveShift]/[deleteShift]
  /// for that.
  Future<Map<DateTime, ShiftDetails>> getAllShifts();

  /// Stores [details] as the shift for [date], overwriting any existing
  /// assignment for that date.
  Future<void> saveShift(DateTime date, ShiftDetails details);

  /// Removes the shift assigned to [date], if any. A no-op if [date] has
  /// no shift. Not called from the UI yet (deleting is out of this
  /// phase's scope) — included now because it's part of the storage
  /// contract this repository is meant to represent.
  Future<void> deleteShift(DateTime date);

  /// Returns every currently-stored Shift Template. A fresh install has
  /// three defaults (Morning/Afternoon/Night) already present — see
  /// AppDatabase's seeding of these on first creation — so this is never
  /// empty in practice, though callers shouldn't rely on that.
  Future<List<ShiftTemplate>> getTemplates();

  /// Stores [template] as a brand-new Shift Template. [template.id] is
  /// ignored (a new id is assigned) — pass a [ShiftTemplate] built without
  /// one.
  Future<void> saveTemplate(ShiftTemplate template);

  /// Overwrites the stored Shift Template with the same id as [template].
  /// [template.id] must not be `null`.
  Future<void> updateTemplate(ShiftTemplate template);

  /// Removes the Shift Template with the given [id], if any. Templates are
  /// presets only — deleting one never touches any already-saved shift
  /// that was originally filled in from it.
  Future<void> deleteTemplate(int id);
}
