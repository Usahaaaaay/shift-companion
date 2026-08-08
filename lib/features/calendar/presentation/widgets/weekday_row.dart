// weekday_row.dart
//
// The Calendar's weekday header row (Mo, Tu, We, ...), sitting directly
// above calendar_grid.dart's date grid. Monday-first, matching the grid's
// own column order — a first-day-of-week preference (FR-SET-4) is a future
// Settings concern, out of scope for this static phase.

import 'package:flutter/material.dart';
import '../../../../core/utils/app_date_format.dart';

/// The seven weekday-abbreviation labels above the Calendar's date grid.
class WeekdayRow extends StatelessWidget {
  /// Creates the Calendar's weekday header row.
  const WeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var weekday = 1; weekday <= 7; weekday++)
          Expanded(
            child: Center(
              child: Text(
                AppDateFormat.weekdayAbbreviation(weekday),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
