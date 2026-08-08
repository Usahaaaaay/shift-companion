// calendar_bottom_sheet.dart
//
// The Calendar's shift-details bottom sheet — shown when a day is
// selected. Presentation only: it renders whatever ShiftDetails
// CalendarScreen's repository currently has for the selected date, via
// DateHeader, ShiftInfoCard, and NotesSection. No editing, no forms, no
// business logic.
//
// Rounded top corners use AppSpacing.radiusLg, matching
// docs/Design_System.md Section 6/7's guidance that a modal bottom sheet
// is exactly the kind of "prominent, full-width surface" that radius (and
// real elevation, rather than the app's usual flat/tonal cards) is for.
//
// PHASE 2.5: this widget is Stateful. [getShift] is a callback into
// CalendarScreen's data, and [onAddShift] is how a newly-chosen shift gets
// written back. The reason this needs its own local state (rather than
// just relying on CalendarScreen's setState) is explained on
// _CalendarBottomSheetState below.
//
// PHASE 3.2A: [getShift]/[onAddShift] are now `Future`-returning, matching
// ShiftRepository's now-asynchronous contract (real SQLite access, once
// DriftShiftRepository is wired in, can't be read synchronously). This
// sheet now loads its data via a held `Future` + `FutureBuilder` instead
// of calling [getShift] directly inside `build()` — the one genuinely
// necessary UI-facing consequence of that interface change, kept as small
// as possible: no new visual states beyond a brief loading spinner while
// the (typically near-instant) query resolves.

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
  required Future<ShiftDetails?> Function(DateTime date) getShift,
  required Future<void> Function(DateTime date, ShiftType type) onAddShift,
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

  /// Reads the current shift for a date from CalendarScreen's repository.
  /// A callback (not a value read once) so this sheet can re-invoke it
  /// after a shift is added, rather than being stuck showing whatever was
  /// true when the sheet first opened.
  final Future<ShiftDetails?> Function(DateTime date) getShift;

  /// Writes a newly-chosen shift type back through CalendarScreen's
  /// repository for [selectedDate].
  final Future<void> Function(DateTime date, ShiftType type) onAddShift;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  /// The in-flight/most-recent read of this sheet's shift. Held in state
  /// (rather than calling `widget.getShift` directly inside `build()`, no
  /// longer possible now that it's async) so [_openShiftPicker] can
  /// reassign it to trigger a refetch without losing track of what's
  /// already loaded.
  late Future<ShiftDetails?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.getShift(widget.selectedDate);
  }

  /// Opens the Shift Picker on top of this sheet, and — once a shift is
  /// chosen — refreshes this sheet in place.
  ///
  /// This sheet's content lives outside CalendarScreen's own widget
  /// subtree (`showModalBottomSheet` mounts it in the Navigator's overlay),
  /// so calling `widget.onAddShift` alone updates CalendarScreen's data
  /// and rebuilds the calendar grid, but does *not* rebuild this
  /// already-open sheet. Reassigning `_detailsFuture` inside `setState` is
  /// what makes that happen: it re-invokes `widget.getShift`, so the
  /// `FutureBuilder` below picks up the change that already happened.
  Future<void> _openShiftPicker() {
    return showShiftPickerBottomSheet(
      context,
      onShiftSelected: (type) async {
        await widget.onAddShift(widget.selectedDate, type);
        if (mounted) {
          setState(() {
            _detailsFuture = widget.getShift(widget.selectedDate);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Roughly half the screen height (within the requested 45–55% band).
    // A fraction rather than a fixed pixel value, so this scales correctly
    // across small phones, large phones, and tablets alike.
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: FutureBuilder<ShiftDetails?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Near-instant for both MemoryShiftRepository and a small
            // SQLite table, so this is a brief flash in practice, not a
            // real loading screen.
            return const Center(child: CircularProgressIndicator());
          }

          final details = snapshot.data;
          return SingleChildScrollView(
            // A scrollable body — rather than assuming the content always
            // fits — so larger system text sizes or a longer note can't
            // cause an overflow within the fixed-height sheet.
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
          );
        },
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
