// date_header.dart
//
// The Calendar bottom sheet's date header: the selected day's weekday on
// one line, day + month on the next. Split out as its own small widget
// (rather than inlined in calendar_bottom_sheet.dart) so the sheet's build
// method stays a simple composition of named pieces, per this phase's own
// "keep widgets small, avoid giant build methods" requirement.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_date_format.dart';

/// Displays [date] as a large weekday line followed by a smaller
/// day-and-month line — reusing the same [AppDateFormat] helpers already
/// shared by GreetingHeader and MonthHeader, so no date-formatting logic
/// (and no hardcoded weekday/month text) is duplicated a third time.
class DateHeader extends StatelessWidget {
  /// Creates the bottom sheet's date header.
  const DateHeader({super.key, required this.date});

  /// The selected date to display.
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppDateFormat.weekday(date),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppDateFormat.dayMonth(date),
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
