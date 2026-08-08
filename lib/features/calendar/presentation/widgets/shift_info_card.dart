// shift_info_card.dart
//
// A Material 3 card summarizing a day's shift — icon, shift type, time
// range, and total hours — shown inside calendar_bottom_sheet.dart.
//
// Colored by shift type via ShiftColors, per this phase's own instruction
// ("future phases will color the card... do not implement that yet unless
// the existing project already exposes shift colors") — it does, as of
// Phase 2.2, so the icon and its backdrop use that existing color mapping
// rather than a flat neutral tone. The card surface itself stays the
// app's default (unthemed) card color; only the icon is tinted, keeping
// this "clean and scalable" rather than a fully colored card.
//
// PHASE 2.5: the time range and hours rows are now only shown when
// present. Shifts created through the Shift Picker (Off/Leave/Public
// Holiday, currently) have no meaningful time range — showing them
// unconditionally would mean rendering "null – null", which is worse than
// simply omitting the row.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_type.dart';
import '../shift_colors.dart';

/// Card summarizing a single day's shift: icon, type, time range, and
/// hours worked.
///
/// Takes a [ShiftDetails] value rather than reading mock data itself, so
/// swapping the data source later (a repository, eventually) only means
/// changing what's passed in from calendar_bottom_sheet.dart — this
/// widget's own code doesn't need to change.
class ShiftInfoCard extends StatelessWidget {
  /// Creates the shift info card.
  const ShiftInfoCard({super.key, required this.details});

  /// The shift to display.
  final ShiftDetails details;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final meta = _metaFor(details.type);
    final shiftColor = ShiftColors.colorFor(details.type);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shiftColor.withValues(alpha: 0.14),
                  ),
                  child: Icon(meta.icon, color: shiftColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  meta.label,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (details.startTime != null && details.endTime != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${details.startTime} – ${details.endTime}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (details.hours != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Hours',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${details.hours} hrs',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Maps a [ShiftType] to the icon and headline label this card shows —
  /// a presentation concern kept out of the domain entity (see
  /// ARCHITECTURE.md). Kept local to this widget rather than shared with
  /// CalendarDayCell's own (differently-phrased) accessibility labels —
  /// a card headline ("Morning Shift") and a screen-reader fragment
  /// ("Morning shift" appended after a date) are different enough text
  /// that forcing one shared mapping would cost more than it'd save for
  /// six short strings.
  static _ShiftMeta _metaFor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return const _ShiftMeta(Icons.wb_sunny_outlined, 'Morning Shift');
      case ShiftType.afternoon:
        return const _ShiftMeta(Icons.light_mode_outlined, 'Afternoon Shift');
      case ShiftType.night:
        return const _ShiftMeta(Icons.dark_mode_outlined, 'Night Shift');
      case ShiftType.off:
        return const _ShiftMeta(Icons.weekend_outlined, 'Day Off');
      case ShiftType.leave:
        return const _ShiftMeta(Icons.beach_access_outlined, 'On Leave');
      case ShiftType.publicHoliday:
        return const _ShiftMeta(Icons.flag_outlined, 'Public Holiday');
    }
  }
}

/// The icon/label a [ShiftInfoCard] needs for a given [ShiftType].
class _ShiftMeta {
  const _ShiftMeta(this.icon, this.label);

  final IconData icon;
  final String label;
}
