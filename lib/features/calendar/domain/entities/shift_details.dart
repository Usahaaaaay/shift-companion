// shift_details.dart
//
// The fuller shift information shown in the Calendar's bottom sheet
// (Phase 2.4) when a day is selected — as opposed to ShiftType, which is
// just the category used to color a calendar cell's dot. Pure Dart, no
// Flutter imports, per ARCHITECTURE.md's domain-layer rule — icons and
// colors for a shift are a presentation concern (see
// ../presentation/shift_colors.dart and shift_info_card.dart's own icon
// mapping), not part of this entity.

import 'shift_type.dart';

/// The full shift information for a single day, as shown in the Calendar's
/// shift-details bottom sheet.
class ShiftDetails {
  /// Creates a description of a day's shift.
  const ShiftDetails({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.hours,
    this.notes,
  });

  /// Which kind of shift this is.
  final ShiftType type;

  /// Formatted start time, e.g. "7:00 AM".
  final String startTime;

  /// Formatted end time, e.g. "4:30 PM".
  final String endTime;

  /// Total hours for the shift, e.g. 9.5.
  final double hours;

  /// An optional free-text note about the shift, e.g. "Covering John's
  /// shift". `null` (or an empty/whitespace-only string) means there's no
  /// note to show.
  final String? notes;
}
