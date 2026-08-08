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
// decides where that data comes from — currently DummyShifts — so a real
// data source later only touches this file, not the grid or cell widgets.
//
// PHASE 2.3: the calendar is now interactive — a single day can be
// selected. The selected date lives here, at the screen level (see
// _selectedDate below), and flows downward through CalendarGrid to
// CalendarDayCell; taps flow back up through a callback. See this file's
// State class for why it's owned here rather than deeper in the tree.
//
// PHASE 2.4: selecting a day now also opens a shift-details bottom sheet
// (see widgets/calendar_bottom_sheet.dart) — the only new behavior this
// phase adds. Selection itself, the grid, month header, and weekday row
// are otherwise untouched.
//
// Unlike the Dashboard, this screen uses a real AppBar — per
// docs/Design_System.md Section 8.8, every screen except the landing tab
// gets one; Calendar isn't the landing tab, so it follows the default.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../dummy_shifts.dart';
import '../widgets/calendar_bottom_sheet.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/month_header.dart';
import '../widgets/weekday_row.dart';

/// The Calendar screen — a monthly grid for the current month, with a
/// single selectable day.
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
  /// CalendarDayCell, for the same reason DummyShifts is read here rather
  /// than by those widgets: this screen is the one place that should know
  /// where the calendar's data (and now its selection) comes from, so
  /// everything beneath it stays a plain function of the values it's
  /// given. A `setState` here is enough — this is transient view state
  /// local to one screen, not app data, so it doesn't need Riverpod (see
  /// decisions/0001-state-management-and-navigation.md, which reserves
  /// Riverpod for state that needs DI or cross-screen sharing; a selected
  /// calendar day is neither).
  DateTime? _selectedDate;

  void _handleDaySelected(DateTime date) {
    // Update selection first (so the selected circle appears immediately
    // behind the sheet), then open the sheet — matching this phase's
    // specified flow: "Selected day updates" before "showModalBottomSheet()".
    setState(() => _selectedDate = date);
    showCalendarBottomSheet(context, selectedDate: date);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final displayedMonth = DateTime(today.year, today.month);
    // TODO(calendar-data): swap for a real shift source (repository +
    // Riverpod provider) once one exists — see dummy_shifts.dart's own
    // FUTURE DATA CONNECTION note.
    final shifts = DummyShifts.forMonth(displayedMonth);

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
                shifts: shifts,
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
