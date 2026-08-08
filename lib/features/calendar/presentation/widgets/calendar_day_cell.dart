// calendar_day_cell.dart
//
// A single day cell in the Calendar's monthly grid (see calendar_grid.dart).
// Renders a date, whether it belongs to the displayed month, whether it's
// today, and — as of Phase 2.2 — a small colored dot when a shift is
// assigned to that date. Per docs/Design_System.md Section 9.2, "today" is
// drawn as a ring around the cell rather than a fill, specifically so it
// can coexist with a shift-type indicator without the two competing for
// the same visual channel; the dot added in Phase 2.2 is exactly that
// coexistence in practice — ring and dot are independent visual channels
// (border vs. small fill) that can both be present on the same cell.
//
// PHASE 2.2: when no shift is assigned (`shiftType == null`), this cell
// renders identically to Phase 2.1 — same widget, same layout, untouched.
// The dot only appears when a shift exists, per this phase's requirement.
// Still no tap handling, no colors beyond the today ring and the shift
// dot, no animation — that stays out of scope for a later phase.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../domain/entities/shift_type.dart';
import '../shift_colors.dart';

/// A single date cell in the Calendar's monthly grid.
class CalendarDayCell extends StatelessWidget {
  /// Creates a calendar day cell.
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    this.shiftType,
  });

  /// The date this cell represents.
  final DateTime date;

  /// Whether [date] falls within the month currently on screen — `false`
  /// for the trailing days of the previous month shown to complete the
  /// first row (see calendar_grid.dart).
  final bool isCurrentMonth;

  /// Whether [date] is today.
  final bool isToday;

  /// The shift assigned to [date], if any. `null` means no shift is
  /// recorded — the cell renders exactly as it did before this phase.
  final ShiftType? shiftType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dayText = Text(
      '${date.day}',
      style: textTheme.bodyLarge?.copyWith(
        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
        color: !isCurrentMonth
            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
            : isToday
            ? colorScheme.primary
            : colorScheme.onSurface,
      ),
    );

    return Semantics(
      label: _semanticLabel(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          // Unchanged from Phase 2.1 — the today ring is a border, drawn
          // independently of the shift dot below, so the two can never
          // visually conflict.
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: shiftType == null
            ? dayText
            // FittedBox guards against overflow on small phones or larger
            // system text-size settings (docs/Design_System.md Section
            // 12/13 — dynamic type must not break a layout) now that a
            // cell can hold a dot plus the day number instead of the
            // number alone.
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ShiftColors.colorFor(shiftType!),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    dayText,
                  ],
                ),
              ),
      ),
    );
  }

  String _semanticLabel() {
    final base = isToday
        ? '${AppDateFormat.fullDate(date)}, today'
        : AppDateFormat.fullDate(date);
    return shiftType == null ? base : '$base, ${_shiftLabel(shiftType!)}';
  }

  /// A human-readable label for [type], used only for accessibility — the
  /// visible cell communicates a shift through color alone (plus the dot's
  /// presence/absence), so a screen-reader user needs the word instead,
  /// per docs/UI_UX_Principles.md Section 15 ("color is never the only
  /// signal").
  static String _shiftLabel(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return 'Morning shift';
      case ShiftType.afternoon:
        return 'Afternoon shift';
      case ShiftType.night:
        return 'Night shift';
      case ShiftType.off:
        return 'Day off';
      case ShiftType.leave:
        return 'On leave';
      case ShiftType.publicHoliday:
        return 'Public holiday';
    }
  }
}
