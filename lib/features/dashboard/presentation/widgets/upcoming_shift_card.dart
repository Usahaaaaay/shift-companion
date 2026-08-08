// upcoming_shift_card.dart
//
// The Dashboard's "Upcoming Shift" section — the next scheduled shift after
// today.
//
// VISUAL REFRESH: dropped the boxed Card treatment entirely in favor of a
// plain block of type on the page background, separated from the sections
// around it by whitespace alone rather than a border or fill — per this
// task's explicit "simplify the design... make it visually secondary to
// Today's Shift" direction, and docs/UI_UX_Principles.md Section 8's "soft,
// quiet separation... through spacing... rather than heavy borders". A
// small eyebrow label keeps the same visual language as TodayShiftCard's
// "TODAY" without the heavy tonal container.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/dashboard_summary.dart';

/// A quiet, unboxed block showing the user's next scheduled shift after
/// today — deliberately the lightest-weight shift summary on the screen.
class UpcomingShiftCard extends StatelessWidget {
  /// Creates the Upcoming Shift section.
  const UpcomingShiftCard({super.key, required this.shift});

  /// The upcoming shift to display.
  final UpcomingShift shift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'UPCOMING SHIFT',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          shift.dayLabel,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${shift.startTime} – ${shift.endTime}',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              shift.department,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (shift.note != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            shift.note!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
