// calendar_bottom_sheet.dart
//
// The Calendar's shift-details bottom sheet — shown when a day is
// selected. Presentation only: it renders whatever ShiftDetails
// CalendarScreen's in-memory state currently has for the selected date
// (Phase 2.5), via DateHeader, ShiftInfoCard, and NotesSection. No
// editing, no persistence, no forms, no business logic.
//
// Rounded top corners use AppSpacing.radiusLg, matching
// docs/Design_System.md Section 6/7's guidance that a modal bottom sheet
// is exactly the kind of "prominent, full-width surface" that radius (and
// real elevation, rather than the app's usual flat/tonal cards) is for.
//
// PHASE 2.5: this widget is now Stateful. It no longer reads a fixed mock
// value — [getShift] is a callback into CalendarScreen's live in-memory
// map, and [onAddShift] is how a newly-chosen shift gets written back to
// it. The reason this needs its own local state (rather than just relying
// on CalendarScreen's setState) is explained on _CalendarBottomSheetState
// below.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_type.dart';
import 'date_header.dart';
import 'notes_section.dart';
import 'shift_info_card.dart';
import 'shift_picker_bottom_sheet.dart';

/// Opens the Calendar's shift-details bottom sheet for [selectedDate].
///
/// A single entry point (rather than every call site constructing
/// `showModalBottomSheet` itself) so the modal's configuration —
/// scroll-controlled sizing, safe-area handling, rounded top corners, the
/// default Material drag handle — only has to be right in one place.
///
/// [selectedDate] is named (rather than positional) so this signature can
/// grow without turning every existing call site into a breaking change to
/// fix — [getShift] and [onAddShift] are exactly that kind of growth,
/// added in Phase 2.5 without touching the call site's `selectedDate:`
/// argument.
Future<void> showCalendarBottomSheet(
  BuildContext context, {
  required DateTime selectedDate,
  required ShiftDetails? Function(DateTime date) getShift,
  required void Function(DateTime date, ShiftType type) onAddShift,
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
    builder: (context) => CalendarBottomSheet(
      selectedDate: selectedDate,
      getShift: getShift,
      onAddShift: onAddShift,
    ),
  );
}

/// The Calendar's shift-details sheet: a date header, then either the
/// day's shift info + notes, or a "no shift scheduled" prompt to add one.
class CalendarBottomSheet extends StatefulWidget {
  /// Creates the shift-details bottom sheet content for [selectedDate].
  const CalendarBottomSheet({
    super.key,
    required this.selectedDate,
    required this.getShift,
    required this.onAddShift,
  });

  /// The selected date this sheet describes.
  final DateTime selectedDate;

  /// Reads the current shift for a date from CalendarScreen's live
  /// in-memory map. A callback (not a value read once) so this sheet can
  /// re-invoke it after a shift is added, rather than being stuck showing
  /// whatever was true when the sheet first opened.
  final ShiftDetails? Function(DateTime date) getShift;

  /// Writes a newly-chosen shift type back to CalendarScreen's in-memory
  /// map for [selectedDate].
  final void Function(DateTime date, ShiftType type) onAddShift;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  /// Opens the Shift Picker on top of this sheet, and — once a shift is
  /// chosen — refreshes this sheet in place.
  ///
  /// This sheet's content lives outside CalendarScreen's own widget
  /// subtree (`showModalBottomSheet` mounts it in the Navigator's overlay),
  /// so calling `widget.onAddShift` alone updates CalendarScreen's data
  /// and rebuilds the calendar grid, but does *not* rebuild this
  /// already-open sheet. The empty `setState` below is what makes that
  /// happen: it doesn't change any state itself, it just tells this sheet
  /// to rebuild, which re-invokes `widget.getShift` and picks up the
  /// change that already happened.
  Future<void> _openShiftPicker() {
    return showShiftPickerBottomSheet(
      context,
      onShiftSelected: (type) {
        widget.onAddShift(widget.selectedDate, type);
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.getShift(widget.selectedDate);

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
            DateHeader(date: widget.selectedDate),
            const SizedBox(height: AppSpacing.lg),
            if (details == null)
              ..._noShiftContent(context)
            else
              ..._shiftContent(details),
          ],
        ),
      ),
    );
  }

  /// Content shown when [widget.selectedDate] has no shift yet.
  List<Widget> _noShiftContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return [
      Text(
        'No shift scheduled',
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      const Divider(),
      const SizedBox(height: AppSpacing.lg),
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: _openShiftPicker,
          icon: const Icon(Icons.add),
          label: const Text('Add Shift'),
        ),
      ),
    ];
  }

  /// Content shown when [widget.selectedDate] already has a shift —
  /// unchanged from Phase 2.4's layout.
  List<Widget> _shiftContent(ShiftDetails details) {
    return [
      ShiftInfoCard(details: details),
      const SizedBox(height: AppSpacing.lg),
      const Divider(),
      const SizedBox(height: AppSpacing.lg),
      NotesSection(notes: details.notes),
    ];
  }
}
