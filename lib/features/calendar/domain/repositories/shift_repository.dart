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

import '../entities/shift_details.dart';

/// A contract for storing and retrieving a single user's shift schedule,
/// keyed by date.
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
}
