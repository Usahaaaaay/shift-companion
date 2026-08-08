// shift_form_bottom_sheet.dart
//
// The Calendar's unified create/edit shift form (Phase 3.3) — the single
// widget used both to create a new shift and to edit an existing one, per
// this phase's "do not create a separate EditShiftDialog" rule. Whether
// it's creating or editing is purely a presentation decision — the title,
// whether fields start blank/default or pre-filled, and whether the
// Delete button shows — never a persistence decision: both paths call the
// same [onSave], which reaches CalendarScreen's `ShiftRepository.saveShift`
// (already an upsert; see that method's own doc comment), so there is no
// separate create-vs-update code path to keep in sync.
//
// Replaces shift_picker_bottom_sheet.dart, which only let a user pick a
// type with no other field — it couldn't be "pre-populated" for editing,
// which this phase requires, so it's superseded rather than kept alongside
// this widget (avoiding exactly the "duplicate dialog" this phase forbids).
//
// A bottom sheet, not a Material Dialog — matching every other Calendar
// interaction sheet, rather than the brief's generic "Dialog" wording. Per
// docs/Design_System.md Section 8.10, a real Dialog is reserved
// specifically for "genuinely destructive, hard-to-reverse confirmations"
// — exactly the delete-confirmation step below, the one place in this
// widget a Dialog actually belongs.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_type.dart';

/// Opens the create/edit shift form for [date].
///
/// Pass [initialShift] to edit an existing shift — fields pre-filled,
/// title reads "Edit Shift", a Delete button appears. Omit it to create a
/// new one — fields start from sensible defaults, title reads
/// "Add Shift", no Delete button. [onSave] and [onDelete] are each called
/// at most once, and this sheet closes itself right after either.
Future<void> showShiftFormBottomSheet(
  BuildContext context, {
  required DateTime date,
  ShiftDetails? initialShift,
  required Future<void> Function(DateTime date, ShiftDetails shift) onSave,
  required Future<void> Function(DateTime date) onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => ShiftFormBottomSheet(
      date: date,
      initialShift: initialShift,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

/// The Calendar's create/edit shift form.
class ShiftFormBottomSheet extends StatefulWidget {
  /// Creates the shift form for [date].
  const ShiftFormBottomSheet({
    super.key,
    required this.date,
    this.initialShift,
    required this.onSave,
    required this.onDelete,
  });

  /// The date this shift belongs to.
  final DateTime date;

  /// The shift being edited, or `null` when creating a new one — the only
  /// thing that distinguishes "create" from "edit" anywhere in this
  /// widget.
  final ShiftDetails? initialShift;

  /// Called with the form's current values when the user taps Save.
  final Future<void> Function(DateTime date, ShiftDetails shift) onSave;

  /// Called when the user confirms deletion (edit mode only).
  final Future<void> Function(DateTime date) onDelete;

  /// Whether this form is editing an existing shift rather than creating
  /// a new one.
  bool get isEditing => initialShift != null;

  @override
  State<ShiftFormBottomSheet> createState() => _ShiftFormBottomSheetState();
}

class _ShiftFormBottomSheetState extends State<ShiftFormBottomSheet> {
  late ShiftType _type;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _hoursController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Editing starts from the stored shift's actual values. Creating
    // starts from ShiftDetails' own sensible defaults (a Morning shift's
    // usual hours) rather than a blank form — the user can freely change
    // or clear anything from there; "defaults", not "required".
    final seed =
        widget.initialShift ?? ShiftDetails.placeholderFor(ShiftType.morning);
    _type = seed.type;
    _startTimeController = TextEditingController(text: seed.startTime ?? '');
    _endTimeController = TextEditingController(text: seed.endTime ?? '');
    _hoursController = TextEditingController(
      text: seed.hours?.toString() ?? '',
    );
    _notesController = TextEditingController(text: seed.notes ?? '');
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// A blank field becomes `null` — matching [ShiftDetails]' own "not
  /// applicable for this shift" convention (see that entity's doc
  /// comments) rather than storing an empty string.
  static String? _blankToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _handleSave() async {
    final shift = ShiftDetails(
      type: _type,
      startTime: _blankToNull(_startTimeController.text),
      endTime: _blankToNull(_endTimeController.text),
      hours: double.tryParse(_hoursController.text.trim()),
      notes: _blankToNull(_notesController.text),
    );
    await widget.onSave(widget.date, shift);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Delete this shift?'),
          content: const Text("This can't be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            // Styled distinctly from routine actions per
            // docs/UI_UX_Principles.md Section 9 ("destructive actions
            // look different").
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await widget.onDelete(widget.date);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        // Room for the on-screen keyboard, so the field being typed into
        // is never covered by it.
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Shift' : 'Add Shift',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<ShiftType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Shift type'),
              items: [
                for (final type in ShiftType.values)
                  DropdownMenuItem(value: type, child: Text(_typeLabel(type))),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start time',
                hintText: 'e.g. 7:00 AM',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: 'Finish time',
                hintText: 'e.g. 4:30 PM',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _hoursController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Hours'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _handleDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete Shift'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// A short, human label for [type] within this form's dropdown — kept
  /// local rather than shared with ShiftInfoCard's differently-phrased
  /// labels ("Morning Shift" there vs. "Morning" here), same reasoning as
  /// that file's own note on why these small mappings aren't forced to
  /// share one definition.
  static String _typeLabel(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return 'Morning';
      case ShiftType.afternoon:
        return 'Afternoon';
      case ShiftType.night:
        return 'Night';
      case ShiftType.off:
        return 'Day Off';
      case ShiftType.leave:
        return 'Leave';
      case ShiftType.publicHoliday:
        return 'Public Holiday';
    }
  }
}
