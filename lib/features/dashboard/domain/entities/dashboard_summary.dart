// dashboard_summary.dart
//
// Domain entities for the Dashboard feature — the plain Dart shapes that
// describe "today's shift", "quick stats", and "the next upcoming shift".
// Per ARCHITECTURE.md, everything in domain/ is pure Dart: no Flutter
// imports, so these types stay testable without a widget tree and don't
// commit the business layer to any particular UI framework. (This is also
// why icons live in presentation/ instead of here — see QuickStatType.)
//
// NOTE: This is currently backed by hardcoded sample data (see
// features/dashboard/presentation/dashboard_mock_data.dart) rather than a
// real repository. When the Dashboard starts reading live shift/leave/
// earnings data, a `DashboardRepository` interface will be added under
// domain/repositories/, implemented under data/repositories/, and exposed
// to the UI through a Riverpod provider in presentation/providers/ — these
// entities are what that whole stack will produce and consume, so no
// changes should be needed here when that happens.

/// The user's live status relative to their shift for today.
///
/// Kept as a closed set (rather than a free-form string) so every place that
/// switches on status — the badge color, the icon, the label — stays
/// exhaustive and in sync as new statuses are added.
enum ShiftStatus {
  /// The shift hasn't started yet.
  upcoming,

  /// The shift is currently in progress.
  workingNow,

  /// The shift has ended for the day.
  finished,

  /// The user has no shift scheduled today.
  dayOff,
}

/// The kind of figure a single Quick Stat tile summarizes.
///
/// Presentation maps each type to its icon and label (see
/// `presentation/widgets/quick_stat_tile.dart`) — kept out of this entity so
/// the domain layer has no Flutter/IconData dependency.
enum QuickStatType {
  /// Total hours worked so far in the current week.
  hoursThisWeek,

  /// When the user's next scheduled shift begins.
  nextShift,

  /// The user's next scheduled leave, if any.
  nextLeave,

  /// Total hours worked so far in the current calendar month.
  thisMonth,
}

/// Today's shift, as shown in the Dashboard's primary "Today's Shift" card.
class TodayShift {
  /// Creates a description of today's shift.
  const TodayShift({
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.department,
    required this.status,
  });

  /// Formatted start time, e.g. "7:00 AM".
  final String startTime;

  /// Formatted end time, e.g. "4:30 PM".
  final String endTime;

  /// Total scheduled hours for the shift, e.g. 9.5.
  final double totalHours;

  /// The department or area the shift is worked in, e.g. "Forecourt".
  final String department;

  /// The user's current status relative to this shift.
  final ShiftStatus status;
}

/// The user's next scheduled shift after today, shown in the "Upcoming
/// Shift" card.
class UpcomingShift {
  /// Creates a description of the next upcoming shift.
  const UpcomingShift({
    required this.dayLabel,
    required this.startTime,
    required this.endTime,
    required this.department,
    this.note,
  });

  /// When the shift falls, relative to today, e.g. "Tomorrow".
  final String dayLabel;

  /// Formatted start time, e.g. "11:00 AM".
  final String startTime;

  /// Formatted end time, e.g. "8:30 PM".
  final String endTime;

  /// The department or area the shift is worked in.
  final String department;

  /// An optional free-text note about the shift (e.g. "Cover for Alex").
  final String? note;
}

/// A single figure shown in the Quick Stats grid (e.g. "Hours This Week").
class QuickStat {
  /// Creates a single Quick Stats figure.
  const QuickStat({required this.type, required this.value, this.subtitle});

  /// Which figure this tile represents.
  final QuickStatType type;

  /// The headline value, e.g. "34.5 hrs" or "None".
  final String value;

  /// An optional secondary line, e.g. "11:00 AM" under a "Tomorrow" value.
  final String? subtitle;
}

/// The full set of data the Dashboard screen needs to render a single,
/// glance-first summary of the user's day.
class DashboardSummary {
  /// Creates a complete Dashboard summary.
  const DashboardSummary({
    required this.greetingName,
    required this.today,
    required this.quickStats,
    required this.motivationalMessage,
    this.upcomingShift,
  });

  /// The name to greet the user with, e.g. "Sheng".
  final String greetingName;

  /// Today's shift summary.
  final TodayShift today;

  /// The four Quick Stats tiles, in display order.
  final List<QuickStat> quickStats;

  /// The next shift after today, if one is scheduled.
  final UpcomingShift? upcomingShift;

  /// A single motivational message to display for this session.
  final String motivationalMessage;
}
