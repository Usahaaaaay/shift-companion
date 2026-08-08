// shift_type.dart
//
// The category a calendar day's shift falls into. Pure Dart, no Flutter
// imports, per ARCHITECTURE.md's domain-layer rule — colors and icons for
// each value are a presentation concern (see ../presentation/shift_colors.dart),
// not part of this entity.
//
// NOTE: deliberately smaller than the full nine-state shift-color system
// sketched in docs/Design_System.md Section 3.4 (which also covers Split
// Shift and Overtime as composite/badge indicators layered on top of a
// primary type, not flat enum values of their own). This is exactly the
// six states this phase's brief asked for; broadening this enum is later
// phases' work, not a gap introduced here.

/// The kind of day a single calendar date represents.
enum ShiftType {
  /// A morning shift.
  morning,

  /// An afternoon shift.
  afternoon,

  /// A night shift.
  night,

  /// A scheduled day off (no shift).
  off,

  /// A day covered by booked leave.
  leave,

  /// A public holiday.
  publicHoliday,
}
