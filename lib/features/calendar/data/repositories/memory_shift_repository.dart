// memory_shift_repository.dart
//
// The current, in-memory ShiftRepository implementation (Phase 2.6) —
// moved here, unchanged in behavior, from what was previously
// CalendarScreen's own private `Map<DateTime, ShiftDetails>` field plus
// its `_normalizeDate`/`_seedDemoShifts` methods. Nothing is persisted:
// every instance starts fresh from the same small demo seed, and all data
// is lost when the instance (and the app) is gone — exactly as before this
// refactor, just now behind a proper repository boundary instead of a
// field the UI could reach into directly.
//
// FUTURE: this is the class a later phase replaces with a Drift-backed
// implementation of the same ShiftRepository contract — see that
// interface's own header comment. This class's constructor is currently
// instantiated once, in routing/app_router.dart, and passed down to
// CalendarScreen; that's the only place a future swap needs to touch.
//
// PHASE 3.2A: every method is now `async`, matching ShiftRepository's now-
// asynchronous contract (see that file's own note on why). Behavior is
// unchanged — an in-memory Map read/write still completes immediately;
// wrapping it in `async` just means callers now get a `Future` that's
// already resolved by the time they see it, not a real delay.

import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_type.dart';
import '../../domain/repositories/shift_repository.dart';

/// An in-memory [ShiftRepository] — the current storage for Shift
/// Companion's shift data. Not persisted; gone when the app restarts.
class MemoryShiftRepository implements ShiftRepository {
  /// Creates a [MemoryShiftRepository], pre-populated with a small demo
  /// set of shifts across the current month (see [_seedDemoShifts]) so the
  /// calendar isn't empty on first launch.
  MemoryShiftRepository() : _shifts = _seedDemoShifts();

  final Map<DateTime, ShiftDetails> _shifts;

  /// Normalizes [date] to a bare year/month/day value (no time-of-day
  /// component), so lookups are never accidentally missed due to an
  /// incidental hour/minute/timezone difference between how a date was
  /// constructed by a caller versus internally.
  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<ShiftDetails?> getShift(DateTime date) async =>
      _shifts[_normalizeDate(date)];

  @override
  Future<Map<DateTime, ShiftDetails>> getAllShifts() async =>
      Map.unmodifiable(_shifts);

  @override
  Future<void> saveShift(DateTime date, ShiftDetails details) async {
    _shifts[_normalizeDate(date)] = details;
  }

  @override
  Future<void> deleteShift(DateTime date) async {
    _shifts.remove(_normalizeDate(date));
  }

  /// A small demo set of shifts across the current month — the exact
  /// dataset CalendarScreen used to seed directly before this repository
  /// existed, unchanged.
  static Map<DateTime, ShiftDetails> _seedDemoShifts() {
    final now = DateTime.now();
    DateTime day(int d) => _normalizeDate(DateTime(now.year, now.month, d));

    return {
      day(2): ShiftDetails.placeholderFor(ShiftType.morning),
      day(3): ShiftDetails.placeholderFor(ShiftType.morning),
      day(23): ShiftDetails.placeholderFor(ShiftType.morning),
      day(5): ShiftDetails.placeholderFor(ShiftType.afternoon),
      day(6): ShiftDetails.placeholderFor(ShiftType.afternoon),
      day(25): ShiftDetails.placeholderFor(ShiftType.afternoon),
      day(8): ShiftDetails.placeholderFor(ShiftType.night),
      day(9): ShiftDetails.placeholderFor(ShiftType.night),
      day(27): ShiftDetails.placeholderFor(ShiftType.night),
      day(12): ShiftDetails.placeholderFor(ShiftType.off),
      day(13): ShiftDetails.placeholderFor(ShiftType.off),
      day(16): ShiftDetails.placeholderFor(ShiftType.leave),
      day(17): ShiftDetails.placeholderFor(ShiftType.leave),
      day(20): ShiftDetails.placeholderFor(ShiftType.publicHoliday),
    };
  }
}
