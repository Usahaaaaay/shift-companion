// calendar_day_cell.dart
//
// A single day cell in the Calendar's monthly grid (see calendar_grid.dart).
// Renders a date, whether it belongs to the displayed month, whether it's
// today, whether it's the selected day, and a small colored dot when a
// shift is assigned to that date. Per docs/Design_System.md Section 9.2,
// "today" is drawn as a ring around the cell rather than a fill,
// specifically so it can coexist with other indicators without competing
// for the same visual channel — the shift dot (Phase 2.2) and the selected
// circle (Phase 2.3) are exactly that coexistence in practice: today's ring
// (a border), the shift dot (a small fill above the number), and the
// selected state (a filled circle around just the number) are three
// independent visual channels that can all be present on one cell at once.
//
// PHASE 2.3: cells are now tappable — but only when [onTap] is provided.
// calendar_grid.dart only wires up taps for dates within the displayed
// month; the previous month's dimmed leading days stay non-interactive in
// this phase (see calendar_grid.dart's own note on why). When neither a
// shift nor a selection applies, this cell renders exactly as it always
// has — same single Text widget, untouched.

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
    this.isSelected = false,
    this.shiftType,
    this.onTap,
  });

  /// The date this cell represents.
  final DateTime date;

  /// Whether [date] falls within the month currently on screen — `false`
  /// for the trailing days of the previous month shown to complete the
  /// first row (see calendar_grid.dart).
  final bool isCurrentMonth;

  /// Whether [date] is today.
  final bool isToday;

  /// Whether this is the single currently-selected day. At most one cell
  /// in the grid should have this `true` at a time — that invariant is
  /// enforced by CalendarScreen (the state owner) and CalendarGrid (which
  /// compares each cell's date against it), not by this widget; this cell
  /// only renders whatever it's told.
  final bool isSelected;

  /// The shift assigned to [date], if any. `null` means no shift is
  /// recorded.
  final ShiftType? shiftType;

  /// Called when this cell is tapped. `null` means the cell isn't
  /// selectable (currently: dates outside the displayed month) — the cell
  /// simply isn't interactive, rather than silently doing nothing on tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color numberColor;
    if (!isCurrentMonth) {
      numberColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (isSelected) {
      // Sits on a filled primary circle below, so it needs the paired
      // "on primary" color for guaranteed contrast — not the plain
      // "today" tint, which would be illegible on that fill.
      numberColor = colorScheme.onPrimary;
    } else if (isToday) {
      numberColor = colorScheme.primary;
    } else {
      numberColor = colorScheme.onSurface;
    }

    final dayNumber = Text(
      '${date.day}',
      style: textTheme.bodyLarge?.copyWith(
        fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
        color: numberColor,
      ),
    );

    // Selection is a filled circle drawn around just the day number —
    // nested inside the cell's own container below, not replacing it, so
    // it can coexist with the today ring and the shift dot.
    final numberWidget = isSelected
        ? Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            child: dayNumber,
          )
        : dayNumber;

    final hasExtraContent = shiftType != null || isSelected;

    final content = !hasExtraContent
        ? numberWidget
        // FittedBox guards against overflow on small phones or larger
        // system text-size settings (docs/Design_System.md Section
        // 12/13 — dynamic type must not break a layout) now that a cell
        // can hold a dot and/or a selected circle in addition to the day
        // number.
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shiftType != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ShiftColors.colorFor(shiftType!),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                numberWidget,
              ],
            ),
          );

    return Semantics(
      label: _semanticLabel(),
      selected: isSelected,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        // Explicit rather than relying on Container's default hit-testing
        // behavior, so the full cell is reliably tappable regardless of
        // whether it happens to be painting a border this frame.
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            // Unchanged from Phase 2.1/2.2 — the today ring is a border,
            // independent of the selected fill and the shift dot, so all
            // three can be visible on the same cell at once.
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: content,
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
