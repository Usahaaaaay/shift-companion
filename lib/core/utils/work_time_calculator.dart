// work_time_calculator.dart
//
// Pure minute arithmetic for turning a shift's start/finish/break into
// worked hours (Phase 3.5 — Automatic Hours Calculation). Lives in
// core/utils/ rather than the calendar feature: nothing here is
// Calendar-specific — it's plain start/end/break minute math any future
// feature (weekly summaries, payroll, statistics, recurring shifts) can
// reuse without duplicating it, matching this phase's own "future phases
// should reuse this utility" instruction. No Flutter import, no UI code,
// no repository/database code — every method is a pure function of the
// integers it's given.
//
// All times are minutes since midnight (0-1439), the same convention
// ShiftTemplate already established in Phase 3.4 (see
// decisions/0003-shift-templates-minutes-storage.md) — this phase extends
// that convention to the shift *form's* Start/Finish fields too (see
// decisions/0004-automatic-hours-calculation.md for why the form's
// previously-free-text Start/Finish fields needed to become structured to
// make this possible).

/// Pure calculations for turning a shift's start/finish/break (all in
/// minutes since midnight) into worked time. Every method is a pure
/// function — no side effects, no I/O — so it's trivially unit-testable
/// and safe to call on every keystroke for live recalculation.
abstract final class WorkTimeCalculator {
  static const int _minutesPerDay = 1440;

  /// Whether a shift starting at [startMinutes] and finishing at
  /// [endMinutes] crosses midnight — i.e. its finish clock-time is earlier
  /// in the day than its start clock-time (e.g. 22:00 -> 06:00). A shift
  /// that starts and finishes at the exact same minute is treated as
  /// zero-length, not a 24-hour wraparound — see [calculateDurationMinutes].
  static bool isOvernight(int startMinutes, int endMinutes) =>
      endMinutes < startMinutes;

  /// The raw clock-time span from [startMinutes] to [endMinutes], in
  /// minutes, ignoring any break. Wraps correctly across midnight using
  /// modular arithmetic rather than string parsing — e.g. start=1320
  /// (22:00), end=360 (06:00) gives 480 minutes (8 hours), not a negative
  /// number.
  ///
  /// `startMinutes == endMinutes` yields 0, not a full 24-hour shift —
  /// there's nothing in a bare start/end pair to distinguish "no time has
  /// passed" from "exactly one full day has passed", and treating it as
  /// zero is the safer, more common-sense default (see [isOvernight]'s own
  /// note on the same case).
  static int calculateDurationMinutes(int startMinutes, int endMinutes) =>
      (endMinutes - startMinutes + _minutesPerDay) % _minutesPerDay;

  /// Whether [breakMinutes] exceeds the raw start-to-finish span — the
  /// shift form surfaces this as a validation error (rather than silently
  /// letting [calculateWorkedMinutes] clamp to zero and leaving the user
  /// wondering why).
  static bool isBreakTooLong({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
  }) => breakMinutes > calculateDurationMinutes(startMinutes, endMinutes);

  /// The actual worked time, in minutes: the raw start-to-finish span
  /// minus [breakMinutes], floored at zero. Never negative, even if
  /// [breakMinutes] exceeds the raw span — see [isBreakTooLong] for
  /// surfacing that case as a validation error instead.
  static int calculateWorkedMinutes({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
  }) {
    final duration = calculateDurationMinutes(startMinutes, endMinutes);
    final worked = duration - breakMinutes;
    return worked < 0 ? 0 : worked;
  }

  /// [calculateWorkedMinutes], expressed in hours (e.g. 450 minutes ->
  /// 7.5). The value this phase persists into `ShiftDetails.hours` —
  /// computed, never typed by the user.
  static double calculateWorkedHours({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
  }) {
    final minutes = calculateWorkedMinutes(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      breakMinutes: breakMinutes,
    );
    return minutes / 60;
  }

  /// Formats [hours] for display, e.g. `8.0`, `7.5`, `5.25` — matching
  /// this phase's brief examples exactly. Rounds to 2 decimal places first
  /// (avoiding floating-point noise like `1.6666666666666667` for a
  /// duration that isn't a clean multiple of an hour), then drops a
  /// trailing zero in the hundredths place so whole- and half-hour shifts
  /// read as `8.0`/`7.5` rather than `8.00`/`7.50`, while a value that
  /// genuinely needs both decimal places (e.g. `5.25`) keeps them.
  static String formatHours(double hours) {
    final rounded = (hours * 100).round() / 100;
    var text = rounded.toStringAsFixed(2);
    if (text.endsWith('0')) text = text.substring(0, text.length - 1);
    return text;
  }
}
