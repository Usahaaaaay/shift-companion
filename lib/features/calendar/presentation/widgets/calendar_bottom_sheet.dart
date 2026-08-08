// calendar_bottom_sheet.dart
//
// The Calendar's shift-details bottom sheet — shown when a day is
// selected. Presentation only: it renders whatever ShiftDetails
// CalendarScreen's repository currently has for the selected date, via
// DateHeader, ShiftInfoCard, and NotesSection, plus (Phase 3.3) an entry
// point into the create/edit form. No business logic — every save/delete
// decision is made by ShiftFormBottomSheet and CalendarScreen; this sheet
// only knows how to open that form and refresh itself afterward.
//
// Rounded top corners use AppSpacing.radiusLg, matching
// docs/Design_System.md Section 6/7's guidance that a modal bottom sheet
// is exactly the kind of "prominent, full-width surface" that radius (and
// real elevation, rather than the app's usual flat/tonal cards) is for.
//
// PHASE 2.5: this widget is Stateful. [getShift] is a callback into
// CalendarScreen's data. The reason this needs its own local state
// (rather than just relying on CalendarScreen's setState) is explained on
// _CalendarBottomSheetState below.
//
// PHASE 3.2A: [getShift] is `Future`-returning, matching ShiftRepository's
// asynchronous contract (real SQLite access can't be read synchronously).
// This sheet loads its data via a held `Future` + `FutureBuilder` instead
// of calling [getShift] directly inside `build()`.
//
// PHASE 3.3: [onAddShift] (create-only, type-only) is replaced by
// [onSaveShift] (create *and* edit, full ShiftDetails) and [onDeleteShift].
// The no-shift view's "Add Shift" button and the new has-shift view's
// "Edit Shift" button both open the same ShiftFormBottomSheet — see that
// file for why there's only one form widget for both cases.
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import 'date_header.dart';
import 'notes_section.dart';
import 'shift_form_bottom_sheet.dart';
import 'shift_info_card.dart';

/// Opens the Calendar's shift-details bottom sheet for [selectedDate].
///
/// A single entry point (rather than every call site constructing
/// `showModalBottomSheet` itself) so the modal's configuration —
/// scroll-controlled sizing, safe-area handling, rounded top corners, the
/// default Material drag handle — only has to be right in one place.
///
/// [selectedDate] is named (rather than positional) so this signature can
/// grow without turning every existing call site into a breaking change to
/// fix — [getShift], [onSaveShift], and [onDeleteShift] are exactly that
/// kind of growth, added across several phases without touching the call
/// site's `selectedDate:` argument.
Future<void> showCalendarBottomSheet(
  BuildContext context, {
  required DateTime selectedDate,
  required Future<ShiftDetails?> Function(DateTime date) getShift,
  required Future<void> Function(DateTime date, ShiftDetails shift) onSaveShift,
  required Future<void> Function(DateTime date) onDeleteShift,
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
      onSaveShift: onSaveShift,
      onDeleteShift: onDeleteShift,
    ),
  );
}

/// The Calendar's shift-details sheet: a date header, then either the
/// day's shift info + notes + an Edit entry point, or a "no shift
/// scheduled" prompt to add one.
class CalendarBottomSheet extends StatefulWidget {
  /// Creates the shift-details bottom sheet content for [selectedDate].
  const CalendarBottomSheet({
    super.key,
    required this.selectedDate,
    required this.getShift,
    required this.onSaveShift,
    required this.onDeleteShift,
  });

  /// The selected date this sheet describes.
  final DateTime selectedDate;

  /// Reads the current shift for a date from CalendarScreen's repository.
  /// A callback (not a value read once) so this sheet can re-invoke it
  /// after a save or delete, rather than being stuck showing whatever was
  /// true when the sheet first opened.
  final Future<ShiftDetails?> Function(DateTime date) getShift;

  /// Writes a created-or-edited shift back through CalendarScreen's
  /// repository for [selectedDate]. The same callback for both cases —
  /// see shift_form_bottom_sheet.dart for why.
  final Future<void> Function(DateTime date, ShiftDetails shift) onSaveShift;

  /// Removes the shift for [selectedDate] through CalendarScreen's
  /// repository.
  final Future<void> Function(DateTime date) onDeleteShift;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  /// The in-flight/most-recent read of this sheet's shift. Held in state
  /// (rather than calling `widget.getShift` directly inside `build()`, not
  /// possible now that it's async) so [_openForm] can reassign it to
  /// trigger a refetch without losing track of what's already loaded.
  late Future<ShiftDetails?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.getShift(widget.selectedDate);
  }

  /// Opens the create/edit form on top of this sheet, and — once it saves
  /// or deletes — refreshes this sheet in place.
  ///
  /// This sheet's content lives outside CalendarScreen's own widget
  /// subtree (`showModalBottomSheet` mounts it in the Navigator's overlay),
  /// so updating CalendarScreen's data alone rebuilds the calendar grid,
  /// but does *not* rebuild this already-open sheet. Reassigning
  /// `_detailsFuture` inside `setState` is what makes that happen: it
  /// re-invokes `widget.getShift`, so the `FutureBuilder` below picks up
  /// whatever changed — a newly created/edited shift, or its absence after
  /// a delete (which naturally falls back to the "no shift scheduled"
  /// view, no special-casing needed).
  Future<void> _openForm({ShiftDetails? initialShift}) {
    return showShiftFormBottomSheet(
      context,
      date: widget.selectedDate,
      initialShift: initialShift,
      onSave: (date, shift) async {
        await widget.onSaveShift(date, shift);
        _refresh();
      },
      onDelete: (date) async {
        await widget.onDeleteShift(date);
        _refresh();
      },
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _detailsFuture = widget.getShift(widget.selectedDate);
      });
    }
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
                  ..._shiftContent(context, details),
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
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Shift'),
        ),
      ),
    ];
  }

  /// Content shown when [widget.selectedDate] already has a shift — the
  /// existing read-only layout, plus (Phase 3.3) an Edit entry point.
  List<Widget> _shiftContent(BuildContext context, ShiftDetails details) {
    return [
      ShiftInfoCard(details: details),
      const SizedBox(height: AppSpacing.md),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openForm(initialShift: details),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Shift'),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      const Divider(),
      const SizedBox(height: AppSpacing.lg),
      NotesSection(notes: details.notes),
    ];
  }
}
