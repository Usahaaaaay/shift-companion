// month_header.dart
//
// The Calendar's month navigation header — "← August 2026 →". Per this
// phase's scope, the chevrons are decorative only: they're rendered as real
// IconButtons (so they look and are labeled like the working control they
// will become) but their `onPressed` is a deliberate no-op.
//
// TODO(calendar-navigation, Phase 2.2): wire these to actually move the
// displayed month backward/forward. That will need CalendarScreen to hold
// which month is displayed as local widget state (`setState`, not Riverpod
// — this is view-local navigation state, not app data) — out of scope here
// per this phase's "no month switching logic" constraint.

import 'package:flutter/material.dart';
import '../../../../core/utils/app_date_format.dart';

/// Shows the currently-displayed month/year with decorative previous/next
/// arrows on either side.
class MonthHeader extends StatelessWidget {
  /// Creates the Calendar's month header.
  const MonthHeader({super.key, required this.month});

  /// The month currently displayed (any date within it — only the month
  /// and year are used).
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          // No-op — see the Phase 2.2 TODO above.
          onPressed: () {},
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous month',
        ),
        Text(
          AppDateFormat.monthYear(month),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next month',
        ),
      ],
    );
  }
}
