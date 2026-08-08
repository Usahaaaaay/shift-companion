// dashboard_mock_data.dart
//
// Hardcoded sample data for the Dashboard screen. Per the current task, this
// screen is read-only with no database, backend, or state management wired
// in — this file is the single, explicit stand-in for all of that.
//
// FUTURE DATA CONNECTION: when the Dashboard starts reading real data, this
// file is what gets deleted. In its place: a `DashboardRepository`
// interface in domain/repositories/, an implementation in data/repositories/
// backed by the Shift Calendar's data source, and a Riverpod provider in
// presentation/providers/ (e.g. `dashboardSummaryProvider`) that
// DashboardScreen reads via `ref.watch` instead of importing this class
// directly. Nothing else in this feature should need to change shape when
// that happens — every other file already consumes a `DashboardSummary`,
// not this mock source.
//
// VISUAL REFRESH: the motivational message is now contextual rather than
// fully random — picked from a small, time-of-day-appropriate list (and a
// separate list for a day off), per this task's Motivation requirements.
// It's still "simple": no AI, no API, just picking among predefined lists
// based on the current time and today's shift status.

import 'dart:math';

import '../domain/entities/dashboard_summary.dart';

/// Provides the hardcoded [DashboardSummary] the Dashboard currently
/// renders.
abstract final class DashboardMockData {
  /// Today's sample shift: a Forecourt shift currently in progress. Kept as
  /// its own field (rather than inlined into [summary]) so
  /// [_contextualMotivationalMessage] can read `today.status` directly
  /// instead of a second, easy-to-forget-to-update copy of it.
  static const TodayShift _today = TodayShift(
    startTime: '7:00 AM',
    endTime: '4:30 PM',
    totalHours: 9.5,
    department: 'Forecourt',
    status: ShiftStatus.workingNow,
  );

  /// A single sample Dashboard summary: today's shift above, plus a shift
  /// scheduled for tomorrow.
  static final DashboardSummary summary = DashboardSummary(
    greetingName: 'Sheng',
    today: _today,
    quickStats: const [
      QuickStat(type: QuickStatType.hoursThisWeek, value: '34.5 hrs'),
      QuickStat(
        type: QuickStatType.nextShift,
        value: 'Tomorrow',
        subtitle: '11:00 AM',
      ),
      QuickStat(type: QuickStatType.nextLeave, value: 'None'),
      QuickStat(type: QuickStatType.thisMonth, value: '172 hrs'),
    ],
    upcomingShift: const UpcomingShift(
      dayLabel: 'Tomorrow',
      startTime: '11:00 AM',
      endTime: '8:30 PM',
      department: 'Forecourt',
      note: 'Stock delivery expected in the afternoon',
    ),
    // Picked once below, from the list matching the current time of day
    // (and today's actual shift status above), rather than per-build — so
    // the message doesn't change every time this screen rebuilds.
    motivationalMessage: _contextualMotivationalMessage(
      hour: DateTime.now().hour,
      isDayOff: _today.status == ShiftStatus.dayOff,
    ),
  );

  /// Messages shown before midday.
  static const List<String> _morningMessages = [
    'Good luck today!',
    'Have a great shift!',
    'Make it a great one.',
  ];

  /// Messages shown from midday until early evening.
  static const List<String> _afternoonMessages = [
    'Keep going!',
    'Almost there.',
    "You're doing great.",
  ];

  /// Messages shown in the evening.
  static const List<String> _eveningMessages = [
    'Great work today.',
    'You made it through the day.',
    'Time to rest up.',
  ];

  /// Messages shown when today has no shift scheduled — takes priority over
  /// the time-of-day lists above.
  static const List<String> _dayOffMessages = [
    'Enjoy your day off.',
    'Relax and recharge.',
    'Make the most of your time off.',
  ];

  /// Picks one message from the list matching the current context.
  ///
  /// `static final summary` above means this only ever runs once per app
  /// session (Dart initializes a `static final` field lazily, on first
  /// access, then caches it) — so the message stays stable for the rest of
  /// the session instead of changing on every rebuild.
  static String _contextualMotivationalMessage({
    required int hour,
    required bool isDayOff,
  }) {
    final pool = isDayOff
        ? _dayOffMessages
        : hour < 12
        ? _morningMessages
        : hour < 17
        ? _afternoonMessages
        : _eveningMessages;
    return pool[Random().nextInt(pool.length)];
  }
}
