// app_date_format.dart
//
// Small, stateless date-formatting helpers shared across features — the
// first real occupant of core/utils/, per this folder's own README ("real
// helpers, e.g. date formatting... will be added as the features that need
// them are implemented"). The Dashboard's GreetingHeader originally had its
// own private weekday/month name lists; now that the Calendar feature needs
// the same names (plus a couple of new formats), this is that promotion —
// one source of truth instead of two copies quietly drifting apart.
//
// Written by hand rather than pulling in the `intl` package — the app
// hasn't taken a dependency on it yet (per ARCHITECTURE.md, localization is
// explicitly undecided until a feature needs it), and a fixed English-only
// set of names is enough for every screen that needs one today.
//
// PHASE 3.4: added [timeOfDayFromMinutes]. Shift Templates store times as
// minutes since midnight rather than formatted strings (see
// features/calendar/domain/entities/shift_template.dart and
// decisions/0003-shift-templates-minutes-storage.md), so applying one to
// the shift form needs exactly this: a presentation-layer conversion back
// to the "7:00 AM"-style text ShiftDetails.startTime/endTime already use
// everywhere else.
//
// PHASE 3.5: added [minutesFromTimeOfDay], [timeOfDayFromMinutes]'s
// inverse. The shift form's Start/Finish fields became structured
// (minutes, picked via a real time picker) so Hours can be calculated
// live via WorkTimeCalculator — see
// decisions/0004-automatic-hours-calculation.md. `ShiftDetails.startTime`/
// `endTime` still persist as formatted strings (no schema change), so
// opening an *existing* shift for editing needs to parse its saved string
// back into minutes once, to seed the picker. This is the only place in
// the app that still parses a time string — live recalculation while
// editing never does, it works from the picked minutes directly.

/// Central place for every weekday/month name and date format used across
/// the app. Screens should call these instead of keeping their own private
/// name lists, so a change here (e.g. eventually supporting localization)
/// only has to happen once.
abstract final class AppDateFormat {
  /// Full weekday names, Monday-first (index 0 = Monday) to match
  /// [DateTime.weekday]'s own 1-based Monday-first numbering.
  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Full month names, January-first (index 0 = January) to match
  /// [DateTime.month]'s own 1-based numbering.
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// The full weekday name for [date], e.g. "Saturday".
  static String weekday(DateTime date) => _weekdays[date.weekday - 1];

  /// A two-letter weekday abbreviation for the given [DateTime.weekday]
  /// value (1 = Monday .. 7 = Sunday), e.g. "Mo", "Tu", "We" — used for the
  /// Calendar's weekday header row. Derived from [_weekdays] rather than a
  /// second hardcoded list, so the two can never drift apart.
  static String weekdayAbbreviation(int weekday) =>
      _weekdays[weekday - 1].substring(0, 2);

  /// The full month name for [date], e.g. "August".
  static String month(DateTime date) => _months[date.month - 1];

  /// Formats [date] as day + month, e.g. "8 August".
  static String dayMonth(DateTime date) => '${date.day} ${month(date)}';

  /// Formats [date] as month + year, e.g. "August 2026" — the Calendar's
  /// month-header format.
  static String monthYear(DateTime date) => '${month(date)} ${date.year}';

  /// Formats [date] as a full, screen-reader-friendly date, e.g.
  /// "Saturday, 8 August 2026".
  static String fullDate(DateTime date) =>
      '${weekday(date)}, ${dayMonth(date)} ${date.year}';

  /// Formats [minutesSinceMidnight] as a 12-hour clock time with AM/PM,
  /// e.g. `420` -> "7:00 AM" — matching the exact style
  /// ShiftDetails.startTime/endTime already use throughout the app, so a
  /// converted Shift Template time looks identical to a hand-typed one.
  ///
  /// [minutesSinceMidnight] is taken modulo a full day first, so an
  /// out-of-range value (there isn't a legitimate one today, but nothing
  /// stops a future caller passing e.g. a raw duration) wraps rather than
  /// producing a nonsensical hour.
  static String timeOfDayFromMinutes(int minutesSinceMidnight) {
    final normalized = minutesSinceMidnight % (24 * 60);
    final hour24 = normalized ~/ 60;
    final minute = normalized % 60;
    final period = hour24 < 12 ? 'AM' : 'PM';
    // Hour 0 (midnight) and hour 12 (noon) both display as "12" on a
    // 12-hour clock; every other hour just wraps into 1-11.
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteText $period';
  }

  /// Attempts to parse [text] as a time in exactly [timeOfDayFromMinutes]'s
  /// own output shape (e.g. "7:00 AM"), returning minutes since midnight —
  /// or `null` if [text] doesn't match that shape at all (e.g. a shift
  /// saved before Phase 3.5, when Start/Finish were free-text fields a
  /// user could type anything into). A non-match is expected to be rare in
  /// practice — every value this app has ever written to `startTime`/
  /// `endTime` already came from either this format's own inverse or one
  /// of [ShiftDetails.placeholderFor]'s fixed strings, both of which match
  /// — but it's handled without throwing regardless, so opening a shift
  /// with a genuinely unparseable saved value degrades to "no time set"
  /// rather than crashing.
  static int? minutesFromTimeOfDay(String text) {
    final match = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])\s*$',
    ).firstMatch(text);
    if (match == null) return null;

    final hour12 = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59) return null;

    // 12:xx AM is midnight (hour 0); 12:xx PM is noon (hour 12); every
    // other hour just shifts by 12 for PM or stays as-is for AM.
    final hour24 = switch ((hour12, isPm)) {
      (12, false) => 0,
      (12, true) => 12,
      (_, true) => hour12 + 12,
      (_, false) => hour12,
    };
    return hour24 * 60 + minute;
  }
}
