// shift_template.dart
//
// A reusable shift preset (Phase 3.4) — "Morning", "Afternoon", "Night", etc.
// Applying one pre-fills the create/edit shift form's Start Time, Finish
// Time, Break, and Notes fields; see shift_form_bottom_sheet.dart for where
// that happens. Pure Dart, no Flutter imports, per ARCHITECTURE.md's
// domain-layer rule — same reasoning as ShiftDetails.
//
// Templates are presets only, not shifts: this entity is never written to
// the `Shifts` table and has no bearing on a day's stored ShiftDetails
// beyond what the user chooses to copy into the form and save.
//
// DESIGN: start/end/break are stored as minutes since midnight (0-1439),
// not formatted strings like "7:00 AM". This is a deliberate departure from
// ShiftDetails' own startTime/endTime (which *are* formatted strings) —
// see decisions/0003-shift-templates-minutes-storage.md for the full
// rationale. In short: templates are the first place in this codebase that
// needs to reason about a time range as a quantity (to eventually compute
// hours, detect overnight spans, sort, etc.), and an integer offset makes
// that arithmetic trivial in a way parsing "7:00 AM" repeatedly never would
// be. Converting a minute value to a human-readable string for display is a
// presentation concern — see core/utils/app_date_format.dart's
// `timeOfDayFromMinutes`, used wherever a template's times reach the UI.

/// A reusable preset of shift values a user can apply to the create/edit
/// shift form instead of typing them by hand.
class ShiftTemplate {
  /// Creates a description of a shift template.
  const ShiftTemplate({
    this.id,
    required this.name,
    required this.startMinutes,
    required this.endMinutes,
    required this.breakMinutes,
    this.notes,
  });

  /// This template's row id, or `null` for a template not yet persisted
  /// (e.g. one being built to pass to [ShiftRepository.saveTemplate]).
  final int? id;

  /// A short, user-facing name, e.g. "Morning".
  final String name;

  /// This template's start time, in minutes since midnight (0-1439).
  final int startMinutes;

  /// This template's finish time, in minutes since midnight (0-1439).
  /// May be numerically less than [startMinutes] for an overnight shift
  /// (e.g. Night: starts at 1320, ends at 360) — callers that need an
  /// actual duration must account for that wraparound themselves.
  final int endMinutes;

  /// This template's default unpaid break length, in minutes.
  final int breakMinutes;

  /// An optional default note copied into the form's Notes field when this
  /// template is applied. `null` (or blank) means no default note.
  final String? notes;
}
