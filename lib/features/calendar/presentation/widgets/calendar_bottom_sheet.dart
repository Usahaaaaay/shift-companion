// calendar_bottom_sheet.dart
//
// The Calendar's shift-details bottom sheet (Phase 2.4) — shown when a day
// is selected. Presentation only: it reads DummyShiftDetails for now and
// renders it via DateHeader, ShiftInfoCard, and NotesSection. No editing,
// no persistence, no forms, no business logic — see this feature's other
// mock-data files for where a real data source will eventually plug in.
//
// Rounded top corners use AppSpacing.radiusLg, matching
// docs/Design_System.md Section 6/7's guidance that a modal bottom sheet
// is exactly the kind of "prominent, full-width surface" that radius (and
// real elevation, rather than the app's usual flat/tonal cards) is for.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../dummy_shift_details.dart';
import 'date_header.dart';
import 'notes_section.dart';
import 'shift_info_card.dart';

/// Opens the Calendar's shift-details bottom sheet for [selectedDate].
///
/// A single entry point (rather than every call site constructing
/// `showModalBottomSheet` itself) so the modal's configuration —
/// scroll-controlled sizing, safe-area handling, rounded top corners, the
/// default Material drag handle — only has to be right in one place.
///
/// [selectedDate] is named (rather than positional) so this signature can
/// grow — e.g. a future `ShiftDetails? shiftDetails` once a repository
/// exists — without turning every existing call site into a breaking
/// change to fix.
Future<void> showCalendarBottomSheet(
  BuildContext context, {
  required DateTime selectedDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // The sheet is sized to a fraction of the screen (see
    // CalendarBottomSheet.build) rather than shrinking to fit its content,
    // which isScrollControlled makes possible.
    isScrollControlled: true,
    useSafeArea: true,
    // Flutter's built-in Material 3 drag handle, per this phase's own
    // "use Flutter's Material 3 style if available" instruction — no need
    // to hand-roll one.
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => CalendarBottomSheet(date: selectedDate),
  );
}

/// The Calendar's shift-details sheet: a date header, the day's shift
/// info, and its notes.
class CalendarBottomSheet extends StatelessWidget {
  /// Creates the shift-details bottom sheet content for [date].
  const CalendarBottomSheet({super.key, required this.date});

  /// The selected date this sheet describes.
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    // TODO(calendar-data): swap for a real shift-details source once one
    // exists — see dummy_shift_details.dart's own FUTURE DATA CONNECTION
    // note. This widget only needs a ShiftDetails, so nothing here has to
    // change shape when that happens.
    final details = DummyShiftDetails.forDate(date);

    // Roughly half the screen height (within the requested 45–55% band).
    // A fraction rather than a fixed pixel value, so this scales correctly
    // across small phones, large phones, and tablets alike.
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: SingleChildScrollView(
        // A scrollable body — rather than assuming the content always
        // fits — so larger system text sizes or a longer note can't cause
        // an overflow within the fixed-height sheet.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateHeader(date: date),
            const SizedBox(height: AppSpacing.lg),
            ShiftInfoCard(details: details),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            NotesSection(notes: details.notes),
          ],
        ),
      ),
    );
  }
}
