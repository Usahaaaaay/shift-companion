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
}
