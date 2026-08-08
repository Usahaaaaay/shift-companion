// calendar_grid.dart
//
// The Calendar's monthly date grid: seven columns (Monday-first, matching
// weekday_row.dart), one row per week needed to fit the month. Leading days
// from the previous month are shown dimmed to complete the first row;
// trailing slots after the month ends are left empty rather than spilling
// into the next month — matching the example layout in this phase's brief,
// and keeping the grid's meaning unambiguous ("blank" always means "not
// this month" without the viewer having to check whether a number belongs
// to the next month instead of the previous one).
//
// Phase 2.1 scope: purely static layout math (which date goes in which
// cell) — no shift data, no colors beyond the "today" ring, no tap
// handling. See calendar_day_cell.dart for the per-cell rendering.
//
// PHASE 2.2: this grid still owns no shift data itself — [shifts] is
// supplied by [CalendarScreen] (currently from DummyShifts) and only
// looked up here per cell, matching the same "widgets render state, they
// don't fetch it" separation dashboard_mock_data.dart already established
// for the Dashboard.
//
// PHASE 2.3: this grid still owns no selection state either — [selectedDate]
// flows down from CalendarScreen the same way [shifts] does, and taps flow
// back up through [onDaySelected] rather than this widget calling setState
// on anything itself. Only dates within the displayed month are wired up
// to [onDaySelected]; the previous month's leading cells stay non-tappable
// in this phase — selecting a day outside the visible month without also
// switching the displayed month would be a confusing, half-built
// interaction, and switching months isn't in this phase's scope.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_type.dart';
import 'calendar_day_cell.dart';

/// The Calendar's monthly grid of [CalendarDayCell]s.
class CalendarGrid extends StatelessWidget {
  /// Creates the Calendar's monthly grid.
  const CalendarGrid({
    super.key,
    required this.month,
    required this.today,
    this.shifts = const {},
    this.selectedDate,
    this.onDaySelected,
  });

  /// The first day of the month currently displayed.
  final DateTime month;

  /// Today's date — passed in from [CalendarScreen] rather than each cell
  /// calling `DateTime.now()` independently, so the whole grid agrees on
  /// what "today" means even if a build happens to straddle midnight.
  final DateTime today;

  /// Shift assignments for the displayed month, keyed by a normalized
  /// (year/month/day-only) date — see `DummyShifts.normalize`. Defaults to
  /// empty so this grid still works exactly as it did in Phase 2.1 for any
  /// caller that doesn't pass shifts.
  final Map<DateTime, ShiftType> shifts;

  /// The single currently-selected date, or `null` if nothing is selected
  /// yet. Compared against each current-month cell's date to decide which
  /// one cell (at most) renders as selected.
  final DateTime? selectedDate;

  /// Called with a date when the user taps a selectable day. `null` means
  /// this grid renders selection state (if any) but doesn't handle taps —
  /// mirrors the same "defaults to inert" shape already used for [shifts].
  final ValueChanged<DateTime>? onDaySelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      // The grid sits inside the screen's own scrolling column, so it must
      // size itself to its content rather than trying to scroll
      // independently — the same pattern already used for the Dashboard's
      // Quick Stats and Quick Actions grids.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 1,
      children: _buildCells(),
    );
  }

  /// Lays out which date (if any) belongs in each grid slot.
  List<Widget> _buildCells() {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday is already Monday(1)..Sunday(7), matching this
    // grid's Monday-first column order, so no remapping is needed.
    final leadingBlanks = month.weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells + 6) ~/ 7;
    final gridSlots = rowCount * 7;

    return List.generate(gridSlots, (index) {
      if (index < leadingBlanks) {
        // A day from the previous month, shown dimmed to complete the
        // first row. DateTime normalizes an out-of-range day (e.g. day 0
        // or negative) by rolling back into the prior month, so this needs
        // no separate "days in previous month" calculation.
        final date = DateTime(
          month.year,
          month.month,
          1 - (leadingBlanks - index),
        );
        return CalendarDayCell(
          date: date,
          isCurrentMonth: false,
          isToday: false,
        );
      }

      final dayOfMonth = index - leadingBlanks + 1;
      if (dayOfMonth > daysInMonth) {
        // Past the end of the month — left empty rather than showing next
        // month's days (see file header).
        return const SizedBox.shrink();
      }

      final date = DateTime(month.year, month.month, dayOfMonth);
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected =
          selectedDate != null &&
          selectedDate!.year == date.year &&
          selectedDate!.month == date.month &&
          selectedDate!.day == date.day;
      return CalendarDayCell(
        date: date,
        isCurrentMonth: true,
        isToday: isToday,
        isSelected: isSelected,
        // Leading (previous-month) cells intentionally never get a shift
        // dot — they're already visually de-emphasized, and dummy_shifts
        // only ever provides data for the displayed month.
        shiftType: shifts[date],
        onTap: onDaySelected == null ? null : () => onDaySelected!(date),
      );
    });
  }
}
