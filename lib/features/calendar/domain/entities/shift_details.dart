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
//
// PHASE 2.6: [ShiftDetails.placeholderFor] moved here from what was
// previously a private static method on CalendarScreen
// (`_detailsForType`), unchanged in behavior. It's needed by both
// MemoryShiftRepository (to build its demo seed data) and CalendarScreen
// (to build a newly-created shift before saving it) — the domain layer is
// the one place both the data layer and the presentation layer are
// already allowed to depend on, so this is where a single, canonical copy
// belongs rather than being duplicated in each.
//
// PHASE 3.4: added [breakMinutes] — a shift's unpaid break length, in
// minutes. Added so a Shift Template's default break (see
// ../entities/shift_template.dart) has somewhere to land when a user
// applies a template and saves the resulting shift; before this, a shift
// had no break concept at all.
//
// PHASE 3.5: [hours] is no longer something a user types — it's calculated
// from [startTime]/[endTime]/[breakMinutes] by
// core/utils/work_time_calculator.dart and written here read-only from the
// shift form's perspective. This entity's own shape is unchanged (still a
// plain nullable `double`); only who computes the value changed. See
// decisions/0004-automatic-hours-calculation.md.

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
    this.breakMinutes,
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

  /// Total hours worked, e.g. 9.5 — calculated from [startTime]/[endTime]/
  /// [breakMinutes] (see core/utils/work_time_calculator.dart), not typed
  /// by the user. `null` for the same reason as [startTime] (no meaningful
  /// time range to calculate from).
  final double? hours;

  /// The shift's unpaid break length, in minutes, e.g. 30. `null` for the
  /// same reason as [startTime] — independent of [hours], which stays the
  /// raw clock span regardless of whether a break is set.
  final int? breakMinutes;

  /// An optional free-text note about the shift, e.g. "Covering John's
  /// shift". `null` (or an empty/whitespace-only string) means there's no
  /// note to show.
  final String? notes;

  /// Builds a placeholder [ShiftDetails] for [type] — a fixed, sensible
  /// time range for the three working shift types, and no time range at
  /// all for the three that don't have one (there's nothing meaningful to
  /// show for a day off). Used wherever a shift needs to be built from
  /// just a chosen type, so a given type looks the same regardless of
  /// whether it came from demo seed data or a user's Shift Picker choice.
  factory ShiftDetails.placeholderFor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return const ShiftDetails(
          type: ShiftType.morning,
          startTime: '7:00 AM',
          endTime: '3:00 PM',
          hours: 8,
        );
      case ShiftType.afternoon:
        return const ShiftDetails(
          type: ShiftType.afternoon,
          startTime: '3:00 PM',
          endTime: '11:00 PM',
          hours: 8,
        );
      case ShiftType.night:
        return const ShiftDetails(
          type: ShiftType.night,
          startTime: '11:00 PM',
          endTime: '7:00 AM',
          hours: 8,
        );
      case ShiftType.off:
      case ShiftType.leave:
      case ShiftType.publicHoliday:
        return ShiftDetails(type: type);
    }
  }
}
