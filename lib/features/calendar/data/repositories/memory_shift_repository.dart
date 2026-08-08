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
//
// PHASE 3.4: added an in-memory Shift Template store, kept in sync with
// what ShiftRepository now requires of every implementation (see that
// interface's own Phase 3.4 note). This class isn't what the running app
// actually uses for storage any more (DriftShiftRepository is, as of Phase
// 3.2B) — it's kept purely so ShiftRepository has a second, dependency
// -free implementation for tests. Its default templates mirror
// AppDatabase's exactly, so either implementation behaves the same way
// from a caller's perspective.

import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_template.dart';
import '../../domain/entities/shift_type.dart';
import '../../domain/repositories/shift_repository.dart';

/// An in-memory [ShiftRepository] — the current storage for Shift
/// Companion's shift data. Not persisted; gone when the app restarts.
class MemoryShiftRepository implements ShiftRepository {
  /// Creates a [MemoryShiftRepository], pre-populated with a small demo
  /// set of shifts across the current month (see [_seedDemoShifts]) so the
  /// calendar isn't empty on first launch, plus the same three default
  /// Shift Templates AppDatabase seeds a fresh SQLite database with.
  MemoryShiftRepository()
    : _shifts = _seedDemoShifts(),
      _templates = _seedDefaultTemplates();

  final Map<DateTime, ShiftDetails> _shifts;

  /// This repository's Shift Templates, keyed by id. A `Map` (rather than
  /// a `List`) so update/delete-by-id are direct lookups instead of a
  /// linear search — the in-memory equivalent of `DriftShiftRepository`
  /// targeting a row by its `id` column.
  final Map<int, ShiftTemplate> _templates;

  /// The next id [saveTemplate] assigns — mimics SQLite's own
  /// auto-incrementing primary key closely enough for this repository's
  /// purposes (never reused within one running instance, which is all
  /// that matters since nothing here persists across restarts anyway).
  int _nextTemplateId = 4;

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

  @override
  Future<List<ShiftTemplate>> getTemplates() async =>
      List.unmodifiable(_templates.values);

  @override
  Future<void> saveTemplate(ShiftTemplate template) async {
    final id = _nextTemplateId++;
    _templates[id] = ShiftTemplate(
      id: id,
      name: template.name,
      startMinutes: template.startMinutes,
      endMinutes: template.endMinutes,
      breakMinutes: template.breakMinutes,
      notes: template.notes,
    );
  }

  @override
  Future<void> updateTemplate(ShiftTemplate template) async {
    // template.id is required to target the existing entry — see
    // ShiftRepository.updateTemplate's own doc comment.
    _templates[template.id!] = template;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    _templates.remove(id);
  }

  /// The same three default Shift Templates AppDatabase seeds a fresh
  /// SQLite database with (see that class's `_insertDefaultTemplates`) —
  /// kept here too so this repository's behavior matches
  /// DriftShiftRepository's from a caller's perspective.
  static Map<int, ShiftTemplate> _seedDefaultTemplates() {
    return {
      1: const ShiftTemplate(
        id: 1,
        name: 'Morning',
        startMinutes: 420,
        endMinutes: 930,
        breakMinutes: 30,
      ),
      2: const ShiftTemplate(
        id: 2,
        name: 'Afternoon',
        startMinutes: 660,
        endMinutes: 1170,
        breakMinutes: 30,
      ),
      3: const ShiftTemplate(
        id: 3,
        name: 'Night',
        startMinutes: 1320,
        endMinutes: 360,
        breakMinutes: 45,
      ),
    };
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
