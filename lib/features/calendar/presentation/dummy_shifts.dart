// dummy_shifts.dart
//
// Hardcoded ShiftType assignments for a handful of dates, so the Calendar
// has something real to render Phase 2.2's shift-color dots against.
// Exactly the same role dashboard_mock_data.dart plays for the Dashboard —
// a temporary, explicit stand-in for real data, not a data layer.
//
// FUTURE DATA CONNECTION: once the Calendar reads real shift data, this
// file is what gets deleted. In its place: a `ShiftRepository` interface in
// domain/repositories/, an implementation in data/repositories/, and a
// Riverpod provider CalendarScreen reads via `ref.watch` — see
// dashboard_mock_data.dart's own comment for the equivalent Dashboard note.
// CalendarScreen is the only place that reads DummyShifts today, so
// swapping the source later touches exactly one file.

import '../domain/entities/shift_type.dart';

/// Provides a small, hardcoded set of [ShiftType]s keyed by date.
abstract final class DummyShifts {
  /// Normalizes [date] to a bare year/month/day value (no time-of-day
  /// component), so lookups into [forMonth]'s map are never accidentally
  /// missed due to an incidental hour/minute/timezone difference between
  /// how a date was constructed here versus by the caller.
  static DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns a map of shift-bearing dates for [month] (any date within the
  /// month the caller wants shifts for — only year/month are used),
  /// spreading a couple of each [ShiftType] across the month so the
  /// Calendar can demonstrate every color at once.
  ///
  /// Takes the displayed month as a parameter (rather than exposing a
  /// fixed, precomputed map) so the sample dates always land inside
  /// whatever month is actually on screen — including once month
  /// navigation exists in a later phase — instead of only ever lining up
  /// with the month this file happened to be written in. Every sample day
  /// number stays at or below 28 so the same set is valid in every month,
  /// including February in a non-leap year.
  static Map<DateTime, ShiftType> forMonth(DateTime month) {
    DateTime day(int d) => normalize(DateTime(month.year, month.month, d));

    return {
      day(2): ShiftType.morning,
      day(3): ShiftType.morning,
      day(23): ShiftType.morning,
      day(5): ShiftType.afternoon,
      day(6): ShiftType.afternoon,
      day(25): ShiftType.afternoon,
      day(8): ShiftType.night,
      day(9): ShiftType.night,
      day(27): ShiftType.night,
      day(12): ShiftType.off,
      day(13): ShiftType.off,
      day(16): ShiftType.leave,
      day(17): ShiftType.leave,
      day(20): ShiftType.publicHoliday,
    };
  }
}
