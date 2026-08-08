// calendar_screen.dart
//
// The Calendar — the app's monthly schedule view, described in
// docs/Software_Requirements.md Section 5.2 and docs/Feature_List.md
// ("Shift Calendar", Core Features).
//
// PHASE 2.1 SCOPE: this screen is purely static — today's real month,
// rendered with no month navigation. It exists so the Calendar tab has
// something real to look at in the emulator before any of that behavior is
// built. See the widgets this screen composes (MonthHeader, WeekdayRow,
// CalendarGrid) for what's deliberately deferred to later phases.
//
// PHASE 2.2: each day can now show a small shift-color dot (see
// CalendarGrid/CalendarDayCell). This screen is still the one place that
// decides where that data comes from — so a real data source later only
// touches this file, not the grid or cell widgets.
//
// PHASE 2.3: the calendar is now interactive — a single day can be
// selected. The selected date lives here, at the screen level (see
// _selectedDate below), and flows downward through CalendarGrid to
// CalendarDayCell; taps flow back up through a callback. See this file's
// State class for why it's owned here rather than deeper in the tree.
//
// PHASE 2.4: selecting a day now also opens a shift-details bottom sheet
// (see widgets/calendar_bottom_sheet.dart) — the only new behavior that
// phase added. Selection itself, the grid, month header, and weekday row
// were otherwise untouched.
//
// PHASE 2.5: this screen now owns a real (if purely in-memory) shift
// map — [_shifts] — instead of reading a fixed dummy source. It's the
// single source of truth for both the calendar's dots (via CalendarGrid)
// and the bottom sheet's details (via getShift/addShift, passed down as
// callbacks). Nothing is persisted: the map is seeded fresh from
// [_seedDemoShifts] every time this screen is created, and any shift
// added through the Shift Picker lives only as long as the app keeps
// running, per this phase's explicit scope.
//
// Unlike the Dashboard, this screen uses a real AppBar — per
// docs/Design_System.md Section 8.8, every screen except the landing tab
// gets one; Calendar isn't the landing tab, so it follows the default.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_type.dart';
import '../widgets/calendar_bottom_sheet.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/month_header.dart';
import '../widgets/weekday_row.dart';

/// The Calendar screen — a monthly grid for the current month, with a
/// single selectable day and in-memory (non-persistent) shift data.
class CalendarScreen extends StatefulWidget {
  /// Creates the Calendar screen.
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// The single currently-selected day, or `null` until the user taps one.
  ///
  /// Owned here — at the screen level — rather than inside CalendarGrid or
  /// CalendarDayCell, for the same reason [_shifts] is owned here rather
  /// than by those widgets: this screen is the one place that should know
  /// where the calendar's data (and its selection) comes from, so
  /// everything beneath it stays a plain function of the values it's
  /// given. A `setState` here is enough — this is transient view state
  /// local to one screen, not app data, so it doesn't need Riverpod (see
  /// decisions/0001-state-management-and-navigation.md, which reserves
  /// Riverpod for state that needs DI or cross-screen sharing; a selected
  /// calendar day is neither).
  DateTime? _selectedDate;

  /// In-memory shift assignments, keyed by a normalized (year/month/day)
  /// date — this prevents duplicate keys for the same calendar day caused
  /// by differing time-of-day components. The single source of truth for
  /// both the calendar's dot indicators and the bottom sheet's shift
  /// details.
  ///
  /// Seeded with a small demo set on every screen creation (see
  /// [_seedDemoShifts]) purely so the calendar isn't empty on first open;
  /// nothing here is persisted, and restarting the app discards it all,
  /// per this phase's explicit scope.
  final Map<DateTime, ShiftDetails> _shifts = _seedDemoShifts();

  /// Normalizes [date] to a bare year/month/day value (no time-of-day
  /// component), so [_shifts] lookups are never accidentally missed due to
  /// an incidental hour/minute/timezone difference between how a date was
  /// constructed here versus by a caller.
  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Builds a placeholder [ShiftDetails] for [type] — a fixed, sensible
  /// time range for the three working shift types, and no time range at
  /// all for the three that don't have one. Shared by [_seedDemoShifts]
  /// and [addShift] so a shift looks the same regardless of whether it was
  /// there from the start or just created through the picker.
  static ShiftDetails _detailsForType(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return const ShiftDetails(
          type: ShiftType.morning,
          startTime: '7:00 AM',
          endTime: '3:00 PM',
          hours: 8,
        );
      case ShiftType.afternoon:
        return const ShiftDetails(
          type: ShiftType.afternoon,
          startTime: '3:00 PM',
          endTime: '11:00 PM',
          hours: 8,
        );
      case ShiftType.night:
        return const ShiftDetails(
          type: ShiftType.night,
          startTime: '11:00 PM',
          endTime: '7:00 AM',
          hours: 8,
        );
      case ShiftType.off:
      case ShiftType.leave:
      case ShiftType.publicHoliday:
        // No meaningful time range for a non-working day — see
        // shift_details.dart and shift_info_card.dart for how `null` is
        // displayed.
        return ShiftDetails(type: type);
    }
  }

  /// A small demo set of shifts across the current month, matching what
  /// the pre-Phase-2.5 dummy data used to show, so the calendar looks the
  /// same on a fresh launch even though it's now backed by real (if
  /// temporary) state instead of a fixed mock source.
  static Map<DateTime, ShiftDetails> _seedDemoShifts() {
    final now = DateTime.now();
    DateTime day(int d) => _normalizeDate(DateTime(now.year, now.month, d));

    return {
      day(2): _detailsForType(ShiftType.morning),
      day(3): _detailsForType(ShiftType.morning),
      day(23): _detailsForType(ShiftType.morning),
      day(5): _detailsForType(ShiftType.afternoon),
      day(6): _detailsForType(ShiftType.afternoon),
      day(25): _detailsForType(ShiftType.afternoon),
      day(8): _detailsForType(ShiftType.night),
      day(9): _detailsForType(ShiftType.night),
      day(27): _detailsForType(ShiftType.night),
      day(12): _detailsForType(ShiftType.off),
      day(13): _detailsForType(ShiftType.off),
      day(16): _detailsForType(ShiftType.leave),
      day(17): _detailsForType(ShiftType.leave),
      day(20): _detailsForType(ShiftType.publicHoliday),
    };
  }

  /// Returns the shift assigned to [date], if any. Passed down to the
  /// bottom sheet as a callback (see calendar_bottom_sheet.dart) rather
  /// than a value, so it can be re-read after [addShift] changes it.
  ShiftDetails? getShift(DateTime date) => _shifts[_normalizeDate(date)];

  /// Records [type] as the shift for [date], overwriting any existing
  /// assignment, and triggers a rebuild so the calendar grid's dot
  /// updates immediately. In-memory only — see this file's header comment.
  void addShift(DateTime date, ShiftType type) {
    setState(() => _shifts[_normalizeDate(date)] = _detailsForType(type));
  }

  void _handleDaySelected(DateTime date) {
    // Update selection first (so the selected circle appears immediately
    // behind the sheet), then open the sheet — matching the established
    // flow: "Selected day updates" before "showModalBottomSheet()".
    setState(() => _selectedDate = date);
    showCalendarBottomSheet(
      context,
      selectedDate: date,
      getShift: getShift,
      onAddShift: addShift,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final displayedMonth = DateTime(today.year, today.month);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthHeader(month: displayedMonth),
              const SizedBox(height: AppSpacing.lg),
              const WeekdayRow(),
              const SizedBox(height: AppSpacing.sm),
              CalendarGrid(
                month: displayedMonth,
                today: today,
                shifts: _shifts,
                selectedDate: _selectedDate,
                onDaySelected: _handleDaySelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
