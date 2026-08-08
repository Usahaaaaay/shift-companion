// shift_details.dart
//
// The fuller shift information shown in the Calendar's bottom sheet
// (Phase 2.4) when a day is selected — as opposed to ShiftType, which is
// just the category used to color a calendar cell's dot. Pure Dart, no
// Flutter imports, per ARCHITECTURE.md's domain-layer rule — icons and
// colors for a shift are a presentation concern (see
// ../presentation/shift_colors.dart and shift_info_card.dart's own icon
// mapping), not part of this entity.
//
// PHASE 2.5: startTime/endTime/hours became optional. Shifts created
// through the new Shift Picker only specify a [type] — there's no time
// range to invent for a "Day Off" or "On Leave" shift, and this phase
// deliberately doesn't add a time-picking step. `null` means "not
// applicable for this shift", not "unknown" — see shift_info_card.dart for
// how that's displayed.

import 'shift_type.dart';

/// The full shift information for a single day, as shown in the Calendar's
/// shift-details bottom sheet.
class ShiftDetails {
  /// Creates a description of a day's shift.
  const ShiftDetails({
    required this.type,
    this.startTime,
    this.endTime,
    this.hours,
    this.notes,
  });

  /// Which kind of shift this is.
  final ShiftType type;

  /// Formatted start time, e.g. "7:00 AM". `null` when this shift type has
  /// no meaningful time range (e.g. a day off).
  final String? startTime;

  /// Formatted end time, e.g. "4:30 PM". `null` for the same reason as
  /// [startTime].
  final String? endTime;

  /// Total hours for the shift, e.g. 9.5. `null` for the same reason as
  /// [startTime].
  final double? hours;

  /// An optional free-text note about the shift, e.g. "Covering John's
  /// shift". `null` (or an empty/whitespace-only string) means there's no
  /// note to show.
  final String? notes;
}
