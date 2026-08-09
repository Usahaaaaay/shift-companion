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
//
// PHASE 3.6 (bug fix): added [formatDuration]/[formatDurationFromHours].
// Manual verification of Template Management surfaced a presentation bug:
// every UI display of worked time went through [formatHours], showing
// decimal hours ("8.83 h") instead of a human-readable "8h 50m". The
// calculation itself was never wrong — [calculateWorkedHours] correctly
// returned 8.8333... hours for a 530-minute shift; only how that value
// then got displayed was the problem. [formatHours] is left exactly as it
// was (still correct, still tested, still available for any future caller
// that genuinely wants decimal hours, e.g. a payroll export) — the two
// display call sites (CalculatedHoursField, ShiftInfoCard) were switched
// to the new formatter instead of it.

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

  /// Whether [breakMinutes] is negative — nonsensical on its own terms (a
  /// break can't last "negative time"), and specifically dangerous here
  /// because [calculateWorkedMinutes] does `duration - breakMinutes`: an
  /// unguarded negative value would *inflate* worked time past the raw
  /// shift span rather than reduce it.
  static bool isNegativeBreak(int breakMinutes) => breakMinutes < 0;

  /// The actual worked time, in minutes: the raw start-to-finish span
  /// minus [breakMinutes], floored at zero. Never negative — not even if
  /// [breakMinutes] exceeds the raw span (see [isBreakTooLong] for
  /// surfacing that as a validation error instead) or is itself negative
  /// (see [isNegativeBreak]) — a negative [breakMinutes] is treated as no
  /// break at all here, rather than silently subtracting a negative
  /// number and inflating the result.
  static int calculateWorkedMinutes({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
  }) {
    final duration = calculateDurationMinutes(startMinutes, endMinutes);
    final safeBreak = breakMinutes < 0 ? 0 : breakMinutes;
    final worked = duration - safeBreak;
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

  /// Formats a worked-time duration, in minutes, as a human-readable
  /// "Xh Ym" string — e.g. `530` -> `"8h 50m"`, `480` -> `"8h"`, `30` ->
  /// `"30m"`, `0` -> `"0m"`. This is the display format every UI shows
  /// worked time in, in place of [formatHours]' decimal form.
  ///
  /// A zero hours or zero minutes component is omitted entirely (never
  /// "0h 50m" or "8h 0m") — except when the whole duration is zero, which
  /// reads as "0m" rather than an empty string.
  static String formatDuration(int minutes) {
    final wholeHours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (wholeHours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${wholeHours}h';
    return '${wholeHours}h ${remainingMinutes}m';
  }

  /// [formatDuration], for callers that only have the already-computed
  /// decimal [hours] value (e.g. [ShiftDetails.hours], read back from
  /// storage) rather than the original integer minutes.
  ///
  /// Rounds `hours * 60` to the nearest minute — safe because every hours
  /// value this app produces came from [calculateWorkedHours], itself
  /// exactly `wholeMinutes / 60`, so this recovers that original integer
  /// exactly (floating-point noise from the division is always well under
  /// half a minute for any duration within a calendar day).
  static String formatDurationFromHours(double hours) =>
      formatDuration((hours * 60).round());
}
