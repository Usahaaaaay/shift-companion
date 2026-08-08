// calendar_screen.dart
//
// The Calendar — the app's monthly schedule view, described in
// docs/Software_Requirements.md Section 5.2 and docs/Feature_List.md
// ("Shift Calendar", Core Features).
//
// PHASE 2.1 SCOPE: this screen is purely static — today's real month,
// rendered with no tap handling, no month navigation, and no state
// management. It exists so the Calendar tab has something real to look at
// in the emulator before any of that behavior is built. See the widgets
// this screen composes (MonthHeader, WeekdayRow, CalendarGrid) for what's
// deliberately deferred to later phases.
//
// PHASE 2.2: each day can now show a small shift-color dot (see
// CalendarGrid/CalendarDayCell). This screen is still the one place that
// decides where that data comes from — currently DummyShifts — so a real
// data source later only touches this file, not the grid or cell widgets.
//
// Unlike the Dashboard, this screen uses a real AppBar — per
// docs/Design_System.md Section 8.8, every screen except the landing tab
// gets one; Calendar isn't the landing tab, so it follows the default.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../dummy_shifts.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/month_header.dart';
import '../widgets/weekday_row.dart';

/// The Calendar screen — a static, read-only monthly grid for the current
/// month.
class CalendarScreen extends StatelessWidget {
  /// Creates the Calendar screen.
  const CalendarScreen({super.key});

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
              CalendarGrid(month: displayedMonth, today: today, shifts: shifts),
            ],
          ),
        ),
      ),
    );
  }
}
