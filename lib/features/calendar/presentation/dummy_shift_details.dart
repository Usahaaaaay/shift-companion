// dummy_shift_details.dart
//
// Hardcoded ShiftDetails for the Calendar's shift-details bottom sheet
// (Phase 2.4). Exactly the same role dashboard_mock_data.dart and
// dummy_shifts.dart already play elsewhere — a temporary, explicit
// stand-in for real data, not a data layer.
//
// Every date currently returns the same placeholder details, per this
// phase's brief ("every selected day can display identical placeholder
// information") — deliberately not cross-referenced against
// DummyShifts' per-date ShiftType map, to avoid introducing lookup/
// reconciliation logic between two mock sources that this presentation-
// only phase doesn't call for. The one visible consequence: the shift
// type named in the bottom sheet won't always match the dot color already
// shown for that day until a later phase gives both a single real source.
//
// FUTURE DATA CONNECTION: once the Calendar reads real shift data, this
// file is what gets deleted, replaced by a `ShiftRepository` (domain/data
// layers) and a Riverpod provider — see dummy_shifts.dart's own comment
// for the equivalent note. CalendarBottomSheet is the only place that
// reads DummyShiftDetails today, so swapping the source later touches
// exactly one file.

import '../domain/entities/shift_details.dart';
import '../domain/entities/shift_type.dart';

/// Provides the hardcoded [ShiftDetails] the Calendar's bottom sheet
/// currently renders.
abstract final class DummyShiftDetails {
  static const ShiftDetails _placeholder = ShiftDetails(
    type: ShiftType.morning,
    startTime: '7:00 AM',
    endTime: '4:30 PM',
    hours: 9.5,
    notes: "Covering John's shift",
  );

  /// Returns the shift details for [date]. Takes the date as a parameter —
  /// even though every date currently returns the same [_placeholder] — so
  /// this call site's shape already matches what a real, per-date data
  /// source will look like, per this phase's "avoid tightly coupling to
  /// mock values" requirement.
  static ShiftDetails forDate(DateTime date) => _placeholder;
}
